import { CODE } from "../config/code";
import { QINIU } from "../config/constant";
import qiniu from 'qiniu';

export default class QiniuService {

    /** 上传七牛云 */
    async getUploadToken() {
        // 参数
        const { accessKey, secretKey, bucketName, uploadUrl } = QINIU
        const options = {
            scope: bucketName,
            expires: 7200, // 7200 秒
            returnBody: `{"url":"${uploadUrl}/$(key)"}`
        }
        try {
            const putPolicy = new qiniu.rs.PutPolicy(options)
            // 鉴权对象
            const mac = new qiniu.auth.digest.Mac(accessKey, secretKey)
            // 生成上传Token
            return {
                token: putPolicy.uploadToken(mac)
            }
        } catch (error) {
            throw (`七牛云鉴权异常：${error}`)
        }
    }
} 