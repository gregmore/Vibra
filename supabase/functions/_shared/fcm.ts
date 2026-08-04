import { optionalEnv } from "./env.ts";

type FcmLegacyPayload = {
  to: string;
  notification: {
    title: string;
    body: string;
  };
  data?: Record<string, string>;
};

/// Invia push via FCM Legacy HTTP API (se FCM_SERVER_KEY è configurata).
/// Se non configurata, ritorna false (no-op) senza far fallire la funzione.
export async function sendFcmLegacy(
  fcmToken: string,
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<boolean> {
  const serverKey = optionalEnv("FCM_SERVER_KEY");
  if (!serverKey) return false;

  const payload: FcmLegacyPayload = {
    to: fcmToken,
    notification: { title, body },
    data,
  };

  const res = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `key=${serverKey}`,
    },
    body: JSON.stringify(payload),
  });

  return res.ok;
}

