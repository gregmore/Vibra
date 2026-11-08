// VIBRA Notification Center (docs/notification-center.md): the one way any
// worker delivers a notification. record_notification (SQL) stores it,
// groups repeats and decides whether a push is allowed (preferences,
// quiet hours, daily caps, blocks). A push is sent only through FCM with
// its configured service account; without it, the notification stays
// in-app.
import { sendFcm } from "./fcm.ts";

export type Delivery = {
  userId: string;
  type: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  actorId?: string | null;
  /** Same key within 12 hours and still unread: grouped, not stacked. */
  groupKey?: string | null;
};

export type DeliveryResult = { stored: boolean; pushed: boolean; grouped: boolean; skipped?: string };

// deno-lint-ignore no-explicit-any
type Rpc = { rpc: (fn: string, args: Record<string, unknown>) => PromiseLike<{ data: any; error: any }> };
export type PushSender = (token: string, title: string, body: string, data: Record<string, string>) => Promise<boolean>;

export async function deliver(db: Rpc, d: Delivery, push: PushSender = sendFcm): Promise<DeliveryResult> {
  const data = d.data ?? {};
  const { data: result, error } = await db.rpc("record_notification", {
    p_user: d.userId,
    p_type: d.type,
    p_title: d.title.slice(0, 200),
    p_body: d.body.slice(0, 500),
    p_data: data,
    p_actor: d.actorId ?? null,
    p_group_key: d.groupKey ?? null,
  });
  if (error) throw error;
  if (!result || result.skipped) return { stored: false, pushed: false, grouped: false, skipped: result?.skipped };
  let pushed = false;
  if (result.push === true && typeof result.token === "string") {
    const count = Number(result.count ?? 1);
    pushed = await push(result.token, d.title, d.body, {
      ...data,
      type: d.type,
      notification_id: String(result.id),
      ...(count > 1 ? { group_count: String(count) } : {}),
    });
  }
  return { stored: true, pushed, grouped: result.grouped === true };
}
