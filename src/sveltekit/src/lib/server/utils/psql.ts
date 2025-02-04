import { env } from "$env/dynamic/private";
import pg from "pg";
const { Pool } = pg;

const createPool = () => {
	console.log(`Establishing database connection.`);
	const pool = new Pool({ connectionString: `postgres://${env.POSTGRES_WEBSERVER_USERNAME}:${env.POSTGRES_WEBSERVER_PASSWORD}@${env.POSTGRES_NETLOC}:${env.POSTGRES_PORT}/lacuna` });
	return {
		query: (queryTextOrConfig: string | pg.QueryConfig<any[]>, values?: any[] | undefined) => {
			return pool.query(queryTextOrConfig, values);
		},
		testConnection: async () => {
			console.log(`Testing database connection.`);
			try {
				const response = await pool.query(
					'SELECT $1::text as message',
					['Database test successful.']
				);
				console.log(response.rows[0].message);
			} catch(e) {
				console.error(`Database test failed: ${e}`);
			}
		},
	};
};

const psql = createPool();
await psql.testConnection();

export default psql;
