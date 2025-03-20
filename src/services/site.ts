import db from '../utils/pool'

export default class SiteService {
    /** 按照domain查询网站配置信息 */
    async getSiteInfo(host: string) {
        const cl = db.collection('site-info');
        const site = await cl.findOne({
            domain: host
        }, {
            projection: { name: 1, contacts: 1, icon: 1, logo: 1, backlogo: 1, description: 1 }
        })

        return site || {}
    }
}