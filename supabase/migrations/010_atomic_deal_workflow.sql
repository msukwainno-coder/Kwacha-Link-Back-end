create or replace function public.confirm_deal_completion(p_deal_id uuid,p_user_id uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare d public.deals%rowtype; o public.offers%rowtype;
begin
 if auth.uid() is distinct from p_user_id then raise exception 'identity mismatch' using errcode='42501'; end if;
 select * into d from public.deals where id=p_deal_id for update;
 if not found or p_user_id not in (d.buyer_id,d.seller_id) then raise exception 'deal not found or forbidden' using errcode='42501'; end if;
 if d.status not in ('pending') then raise exception 'deal is not pending' using errcode='22023'; end if;
 if p_user_id=d.buyer_id then if d.buyer_confirmed_at is not null then raise exception 'already confirmed' using errcode='22023'; end if; update public.deals set buyer_confirmed_at=now(),updated_at=now() where id=d.id returning * into d;
 else if d.seller_confirmed_at is not null then raise exception 'already confirmed' using errcode='22023'; end if; update public.deals set seller_confirmed_at=now(),updated_at=now() where id=d.id returning * into d; end if;
 if d.buyer_confirmed_at is not null and d.seller_confirmed_at is not null then
   select * into o from public.offers where id=d.offer_id for update;
   if not found or o.status not in ('active','paused') or o.remaining_amount<d.amount then raise exception 'offer unavailable or insufficient balance' using errcode='22023'; end if;
   update public.offers set remaining_amount=remaining_amount-d.amount,status=case when remaining_amount-d.amount=0 then 'filled' else status end,updated_at=now() where id=o.id;
   update public.deals set status='completed',updated_at=now() where id=d.id returning * into d;
 end if;
 return to_jsonb(d);
end $$;
revoke all on function public.confirm_deal_completion(uuid,uuid) from public,anon; grant execute on function public.confirm_deal_completion(uuid,uuid) to authenticated;
create or replace function public.cancel_deal_by_participant(p_deal_id uuid,p_user_id uuid) returns jsonb language plpgsql security definer set search_path=public as $$ declare d public.deals%rowtype; begin if auth.uid() is distinct from p_user_id then raise exception 'identity mismatch' using errcode='42501'; end if; select * into d from public.deals where id=p_deal_id for update; if not found or p_user_id not in(d.buyer_id,d.seller_id) then raise exception 'deal not found or forbidden' using errcode='42501'; end if; if d.status<>'pending' then raise exception 'only pending deals can be cancelled' using errcode='22023'; end if; update public.deals set status='cancelled',updated_at=now() where id=d.id returning * into d; return to_jsonb(d); end $$;
revoke all on function public.cancel_deal_by_participant(uuid,uuid) from public,anon; grant execute on function public.cancel_deal_by_participant(uuid,uuid) to authenticated;
