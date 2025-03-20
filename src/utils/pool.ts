import { DATABASE, ENV } from "../config/constant";
import { MongoClient } from 'mongodb';

const { dbName, user, password, host, port } =
  process.env.NODE_ENV === ENV.production
    ? DATABASE.production
    : DATABASE.development;
const uri = `mongodb://${user}:${password}@${host}:${port}/?authSource=${dbName}`

const client = new MongoClient(uri);

/** 建立连接 */
client.connect();

/** 连接数据库 */
const db = client.db(dbName);
export default db;