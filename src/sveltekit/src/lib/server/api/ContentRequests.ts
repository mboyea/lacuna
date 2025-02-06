import psql from "$lib/server/utils/psql";
import type { EditableContent } from "$lib/types/EditableContent";

export const getContentById = async (id: number): Promise<EditableContent | null> => {
  const response = await psql.query(`
    SELECT id, publish_date, last_edit_date, markdown
    FROM editable_content
    WHERE id='${id}'
  `);
  if ((response.rowCount ?? 0) !== 1) {
    return null;
  }
  const result = response.rows[0];
  return {
    id: result.id,
    publishDate: result.publish_date,
    lastEditDate: result.last_edit_date,
    markdown: result.markdown,
  }
}
