import OpenAI from "openai";
export default class TimeService {

    /** 调用AI接口获取诗词句 */
    async getVerse(author: string) {
        const openai = new OpenAI(
            {
                apiKey:  'sk-caba1a0e93254c6a970547eb8647c807',
                baseURL:  "https://dashscope.aliyuncs.com/compatible-mode/v1",
            }
        )

        const completion = await openai.chat.completions.create({
            model: "qwen-plus-latest",  //模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models
            messages: [
                { role: "system", content: "你擅长古诗词句，根据给出的历史人物名字，随机生成这个人物作的一句诗词。诗词不允许重复。不需要解释。我的历史人物名字是：${keyword}" },
                { role: "user", content: author }
            ],
        });

        return completion.choices[0].message.content
    }
} 




