import { json, type ServerLoad } from "@sveltejs/kit";
import { getContentById } from "$lib/server/api/ContentRequests";

export const GET: ServerLoad = async ({ params }) => {
  const contentId = parseInt(params.slug || 'a');
  if (!Number.isInteger(contentId)) {
    return json('Invalid content ID.', { status: 400 });
  }
  const result = getContentById(contentId);
  if (result === null) {
    return json('Content not found.', { status: 404 })
  }
  return json(result, { status: 200 })
}
