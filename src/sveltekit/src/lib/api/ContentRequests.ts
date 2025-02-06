import type { EditableContent } from "$lib/types/EditableContent";

export const getContent = async (slug: string, fetchCallback = fetch): Promise<EditableContent | null> => {
  const route = `/api/v1/content/${slug}`;
  const request: RequestInit = {
    method: 'GET',
    redirect: 'follow',
  };
  const response = await fetchCallback(route, request);
  if (!response.ok) {
    throw new Error(
      `${response.status} - ${JSON.stringify(await response.json())}`
    );
  }
  return await response.json() as Promise<EditableContent>;
}
