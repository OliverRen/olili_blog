---
title: dotNetWebAPI文档框架-Swagger
tags: 小书匠语法,技术
renderNumberedHeading: true
grammar_abbr: true
grammar_table: true
grammar_defList: true
grammar_emoji: true
grammar_footnote: true
grammar_ins: true
grammar_mark: true
grammar_sub: true
grammar_sup: true
grammar_checkbox: true
grammar_mathjax: true
grammar_flow: true
grammar_sequence: true
grammar_plot: true
grammar_code: true
grammar_highlight: true
grammar_html: true
grammar_linkify: true
grammar_typographer: true
grammar_video: true
grammar_audio: true
grammar_attachment: true
grammar_mermaid: true
grammar_classy: true
grammar_cjkEmphasis: true
grammar_cjkRuby: true
grammar_center: true
grammar_align: true
grammar_tableExtra: true
---

[toc]

> 当然如果只是轻量级的文档编写,共享强烈推荐 API文档工具Rap2,编写起来特别的快,通过拷贝json直接读取所有属性和字段.
rap2是挺好的，但是和swagger比起来有点轻量。

#### swagger的生态使用图：

![其中，红颜色的是swagger官网方推荐的](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106567.png)

#### swagger的生态的具体内容：

**swagger-ui**
用来显示API文档的。和rap不同的是，它不可以编辑。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106676.jpg)

**swagger-editor**
就是一个在线编辑文档说明文件（swagger.json或swagger.yaml文件）的工具，以方便生态中的其他小工具（swagger-ui）等使用。 
左边编辑，右边立马就显示出编辑内容来。编辑swagger说明文件使用的是==yaml语法==.

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106774.jpg)

目前最流行的做法，就是在代码注释中写上swagger相关的注释，然后，利用小工具生成swagger.json或者swagger.yaml文件。

#### swagger的引用
1. nuget引用 Swashbuckle

2. 修改SwaggerConfig.cs,比如版本号 和 title

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106767.png)

3. 创建项目XML注释文档
在==项目== -> ==属性== -> ==生成== -> 选中 ==XML文档生成==

然后在配置中启用,需要注意xml文档的位置:
`c.IncludeXmlComments(string.Format("{0}/bin/BjxWebApis.XML",System.AppDomain.CurrentDomain.BaseDirectory));`
一般都是有的,只需要取消注释后改一下就好了

4. 启动项目
访问启动路径 /swagger即可,如 `http://localhost:58303/swagger`

#### 使用问题处理

1. action 方法名称相同处理
`c.ResolveConflictingActions(apiDescriptions => apiDescriptions.First());`

2. 序列化出来的JSON NULL 值处理
通过F12分析,是由于 Newtonsoft.json处理Null字段的问题
`settings.NullValueHandling = NullValueHandling.Ignore;`

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106769.png)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106671.png)

#### 汉化及Controller说明

1. 定义一个provider实现ISwaggerProvider接口 包含了缓存 名：SwaggerCacheProvider
``` csharp
/// <summary>
    /// swagger显示控制器的描述
    /// </summary>
    public class SwaggerCacheProvider : ISwaggerProvider
    {
        private readonly ISwaggerProvider _swaggerProvider;
        private static ConcurrentDictionary<string, SwaggerDocument> _cache =new ConcurrentDictionary<string, SwaggerDocument>();
        private readonly string _xml;
        /// <summary>
        ///
        /// </summary>
        /// <param name="swaggerProvider"></param>
        /// <param name="xml">xml文档路径</param>
        public SwaggerCacheProvider(ISwaggerProvider swaggerProvider,string xml)
        {
            _swaggerProvider = swaggerProvider;
            _xml = xml;
        }

        public SwaggerDocument GetSwagger(string rootUrl, string apiVersion)
        {

            var cacheKey = string.Format("{0}_{1}", rootUrl, apiVersion);
            SwaggerDocument srcDoc = null;
            //只读取一次
            if (!_cache.TryGetValue(cacheKey, out srcDoc))
            {
                srcDoc = _swaggerProvider.GetSwagger(rootUrl, apiVersion);

                srcDoc.vendorExtensions = new Dictionary<string, object> { { "ControllerDesc", GetControllerDesc() } };
                _cache.TryAdd(cacheKey, srcDoc);
            }
            return srcDoc;
        }

        /// <summary>
        /// 从API文档中读取控制器描述
        /// </summary>
        /// <returns>所有控制器描述</returns>
        public  ConcurrentDictionary<string, string> GetControllerDesc()
        {
            string xmlpath = _xml;
            ConcurrentDictionary<string, string> controllerDescDict = new ConcurrentDictionary<string, string>();
            if (File.Exists(xmlpath))
            {
                XmlDocument xmldoc = new XmlDocument();
                xmldoc.Load(xmlpath);
                string type = string.Empty, path = string.Empty, controllerName = string.Empty;

                string[] arrPath;
                int length = -1, cCount = "Controller".Length;
                XmlNode summaryNode = null;
                foreach (XmlNode node in xmldoc.SelectNodes("//member"))
                {
                    type = node.Attributes["name"].Value;
                    if (type.StartsWith("T:"))
                    {
                        //控制器
                        arrPath = type.Split('.');
                        length = arrPath.Length;
                        controllerName = arrPath[length - 1];
                        if (controllerName.EndsWith("Controller"))
                        {
                            //获取控制器注释
                            summaryNode = node.SelectSingleNode("summary");
                            string key = controllerName.Remove(controllerName.Length - cCount, cCount);
                            if (summaryNode != null && !string.IsNullOrEmpty(summaryNode.InnerText) && !controllerDescDict.ContainsKey(key))
                            {
                                controllerDescDict.TryAdd(key, summaryNode.InnerText.Trim());
                            }
                        }
                    }
                }
            }
            return controllerDescDict;
        }
    }
```

2. 定义一个JS文件,做成嵌入资源，这个js文件的功能主要有两个，一个是汉化，另一个就是在界面上显示控制器的描述文字

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106673.png)

JS资源文件命名空间是：文件所在项目的命名空间.文件径路.文件名
``` javascript
'use strict';
window.SwaggerTranslator = {
    _words: [],

    translate: function () {
        var $this = this;
        $('[data-sw-translate]').each(function () {
            $(this).html($this._tryTranslate($(this).html()));
            $(this).val($this._tryTranslate($(this).val()));
            $(this).attr('title', $this._tryTranslate($(this).attr('title')));
        });
    },

    setControllerSummary: function () {

        try
        {
            console.log($("#input_baseUrl").val());
            $.ajax({
                type: "get",
                async: true,
                url: $("#input_baseUrl").val(),
                dataType: "json",
                success: function (data) {

                    var summaryDict = data.vendorExtensions.ControllerDesc;
                    console.log(summaryDict);
                    var id, controllerName, strSummary;
                    $("#resources_container .resource").each(function (i, item) {
                        id = $(item).attr("id");
                        if (id) {
                            controllerName = id.substring(9);
                            try {
                                strSummary = summaryDict[controllerName];
                                if (strSummary) {
                                    $(item).children(".heading").children(".options").first().prepend('<li class="controller-summary" style="color:green;" title="' + strSummary + '">' + strSummary + '</li>');
                                }
                            } catch (e)
                            {
                                console.log(e);
                            }
                        }
                    });
                }
            });
        }catch(e)
        {
            console.log(e);
        }
    },
    _tryTranslate: function (word) {
        return this._words[$.trim(word)] !== undefined ? this._words[$.trim(word)] : word;
    },

    learn: function (wordsMap) {
        this._words = wordsMap;
    }
};


/* jshint quotmark: double */
window.SwaggerTranslator.learn({
    "Warning: Deprecated": "警告：已过时",
    "Implementation Notes": "实现备注",
    "Response Class": "响应类",
    "Status": "状态",
    "Parameters": "参数",
    "Parameter": "参数",
    "Value": "值",
    "Description": "描述",
    "Parameter Type": "参数类型",
    "Data Type": "数据类型",
    "Response Messages": "响应消息",
    "HTTP Status Code": "HTTP状态码",
    "Reason": "原因",
    "Response Model": "响应模型",
    "Request URL": "请求URL",
    "Response Body": "响应体",
    "Response Code": "响应码",
    "Response Headers": "响应头",
    "Hide Response": "隐藏响应",
    "Headers": "头",
    "Try it out!": "试一下！",
    "Show/Hide": "显示/隐藏",
    "List Operations": "显示操作",
    "Expand Operations": "展开操作",
    "Raw": "原始",
    "can't parse JSON.  Raw result": "无法解析JSON. 原始结果",
    "Model Schema": "模型架构",
    "Model": "模型",
    "apply": "应用",
    "Username": "用户名",
    "Password": "密码",
    "Terms of service": "服务条款",
    "Created by": "创建者",
    "See more at": "查看更多：",
    "Contact the developer": "联系开发者",
    "api version": "api版本",
    "Response Content Type": "响应Content Type",
    "fetching resource": "正在获取资源",
    "fetching resource list": "正在获取资源列表",
    "Explore": "浏览",
    "Show Swagger Petstore Example Apis": "显示 Swagger Petstore 示例 Apis",
    "Can't read from server.  It may not have the appropriate access-control-origin settings.": "无法从服务器读取。可能没有正确设置access-control-origin。",
    "Please specify the protocol for": "请指定协议：",
    "Can't read swagger JSON from": "无法读取swagger JSON于",
    "Finished Loading Resource Information. Rendering Swagger UI": "已加载资源信息。正在渲染Swagger UI",
    "Unable to read api": "无法读取api",
    "from path": "从路径",
    "server returned": "服务器返回"
});
$(function () {
    window.SwaggerTranslator.translate();
    window.SwaggerTranslator.setControllerSummary();
});
```

3. 修改 SwaggerConfig,主要代码有两行:
``` csharp
c.CustomProvider((defaultProvider) => new SwaggerCacheProvider(defaultProvider, string.Format("{0}/bin/BjxWebApis.XML", System.AppDomain.CurrentDomain.BaseDirectory)));

c.InjectJavaScript(System.Reflection.Assembly.GetExecutingAssembly(), "BjxWebApis.swagger.js");
```

#### 统一返回 HttpResponseMessage

使用SwaggerResponse 指定返回类型，两个httpstatuscode 对应不同返回值

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106674.png)

#### 自定义 HTTP Header
验证参数请求头,我们需要创建一个 IOperationFilter接口的类
SwaggerConfig.cs 配置中加入  `c.OperationFilter<HttpAuthHeaderFilter>();`

``` csharp
/// <summary>
    /// swagger 增加 AUTH 选项
    /// </summary>
    public class HttpAuthHeaderFilter : IOperationFilter
    {
        /// <summary>
        /// 应用
        /// </summary>
        /// <param name="operation"></param>
        /// <param name="schemaRegistry"></param>
        /// <param name="apiDescription"></param>
        public void Apply(Operation operation, SchemaRegistry schemaRegistry, ApiDescription apiDescription)

        {
            if (operation.parameters == null)
                operation.parameters = new List<Parameter>();
            var filterPipeline = apiDescription.ActionDescriptor.GetFilterPipeline(); //判断是否添加权限过滤器
            var isAuthorized = filterPipeline.Select(filterInfo => filterInfo.Instance).Any(filter => filter is IAuthorizationFilter); //判断是否允许匿名方法
            var allowAnonymous = apiDescription.ActionDescriptor.GetCustomAttributes<AllowAnonymousAttribute>().Any();
            if (isAuthorized && !allowAnonymous)
            {
                operation.parameters.Add(new Parameter { name = "Authorization", @in = "header", description = "安全", required = false, type = "string" });
            }
        }
    }
```

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106675.png)

#### 请求示例

效果如图:
![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/dotNetWebAPI文档框架-Swagger/2020811/1597125106768.png)

要想实现这个效果 ，我们需要在注释中使用remarks标签.
看写法，需要说明的是 \<remarks>前有个空格  请求地址 空格+tab 才能出来上面效果