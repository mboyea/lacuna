import { POSTGRES_WEBSERVER_USERNAME, POSTGRES_WEBSERVER_PASSWORD } from "$env/static/private";
import pg from "pg";
const { Pool } = pg;

const createPool = () => {
	console.log(`Establishing database connection.`);
	const pool = new Pool({ connectionString: `postgres://${POSTGRES_WEBSERVER_USERNAME}:${POSTGRES_WEBSERVER_PASSWORD}@localhost:5432/lacuna` });
	return {
		query: (queryTextOrConfig: string | pg.QueryConfig<any[]>, values?: any[] | undefined) => {
			return pool.query(queryTextOrConfig, values);
		},
		testConnection: async () => {
			console.log(`Testing database connection.`);
			try {
				const response = await pool.query(
					'SELECT $1::text as message',
					['Test successful.']
				);
				console.log(response.rows[0].message);
			} catch(e) {
				console.error(`Test failed: ${e}`);
			}
		},
	};
};

const psql = createPool();
await psql.testConnection();

export default psql;
