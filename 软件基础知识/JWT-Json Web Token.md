---
title: JWT-JsonWebToken
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

#### 为什么是 JWT Bearer

> ASP.NET Core 在 Microsoft.AspNetCore.Authentication 下实现了一系列认证, 包含 Cookie, JwtBearer, OAuth, OpenIdConnect 等

*   Cookie 认证是一种比较常用本地认证方式, 它由浏览器自动保存并在发送请求时自动附加到请求头中, 更适用于 MVC 等纯网页系统的本地认证.
*   OAuth & OpenID Connect 通常用于运程认证, 创建一个统一的认证中心, 来统一配置和处理对于其他资源和服务的用户认证及授权.
*   JwtBearer 认证中, 客户端通常将 JWT(一种Token) 通过 HTTP 的 Authorization header 发送给服务端, 服务端进行验证. 可以方便的用于 WebAPI 框架下的本地认证.
	当然, 也可以完全自己实现一个WebAPI下基于Token的本地认证, 比如自定义Token的格式, 自己写颁发和验证Token的代码等. 这样的话通用性并不好, 而且也需要花费更多精力来封装代码以及处理细节.
	
-------------

#### JSON Web Token是什么

JSON Web Token (JWT)是一个开放标准(RFC 7519)，它定义了一种紧凑的、自包含的方式，用于作为JSON对象在各方之间安全地传输信息。该信息可以被验证和信任，因为它是数字签名的。

**JSON Web Token的结构**

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172952.png)

JWT通常由三部分组成: 头信息（header）, 消息体（payload）和签名（signature）。
头信息指定了该JWT使用的签名算法：
`header = {"alg": "HS256", "typ": "JWT"}`
消息体包含了JWT的意图：
`payload = {"sub": "1234567890", "name": "John Doe", "iat": 1516239022}`
未签名的令牌由base64url编码的头信息和消息体拼接而成（使用"."分隔），签名则通过私有的key计算而成：
```
key = "secretkey" 
unsignedToken = base64UrlEncode(header) + '.' + base64UrlEncode(payload)  
signature = HMAC-SHA256(key, unsignedToken) 
```
最后在尾部拼接上base64url编码的签名（同样使用"."分隔）就是JWT了：
`token = base64UrlEncode(header) + '.' + base64UrlEncode(payload) + '.' + base64UrlEncode(signature) `

因此，一个典型的JWT看起来是这个样子的：
`xxxxx.yyyyy.zzzzz`

> 对payload进行Base64编码就得到JWT的第二部分注意，不要在JWT的payload或header中放置敏感信息，除非它们是加密的。
> 非对称加密中,公钥加密,私钥解密.反过来 私钥签名,公钥验签

------------------

#### JWT的优缺点
优点有：
1.  更适用分布式和水平扩展
    在cookie-session方案中，cookie内仅包含一个session标识符，而诸如用户信息、授权列表等都保存在服务端的session中。如果把session中的认证信息都保存在JWT中，在服务端就没有session存在的必要了。当服务端水平扩展的时候，就不用处理session复制（session replication）/ session黏连（sticky session）或是引入外部session存储了。
2.  适用于多客户端（特别是移动端）的前后端解决方案
    移动端使用的往往不是网页技术，使用Cookie验证并不是一个好主意，因为你得和Cookie容器打交道，而使用Bearer验证则简单的多。
3.  无状态化
    JWT 是无状态化的，更适用于 RESTful 风格的接口验证。
	
缺点也很明显：
1.  更多的空间占用
    JWT 由于Payload里面包含了附件信息，占用空间往往比SESSION ID大，在HTTP传输中会造成性能影响。所以在设计时候需要注意不要在JWT中存储太多的claim,以避免发生巨大的,过度膨胀的请求。
2.  无法作废已颁布的令牌
    所有的认证信息都在JWT中，由于在服务端没有状态，即使你知道了某个JWT被盗取了，你也没有办法将其作废。在JWT过期之前（你绝对应该设置过期时间），你无能为力。
	tips:其实也是可以的,可选的方案是做成紧急黑名单配置在应用下或者cache在内存里来在令牌有效时间内拒绝服务.

-------------------

#### 什么时候你应该用JWT

下列场景中使用JSON Web Token是很有用的：

*   Authorization (授权) : 这是使用JWT的最常见场景。一旦用户登录，后续每个请求都将包含JWT，允许用户访问该令牌允许的路由、服务和资源。单点登录是现在广泛使用的JWT的一个特性，因为它的开销很小，并且可以轻松地跨域使用。
*   Information Exchange (信息交换) : 对于安全的在各方之间传输信息而言，JSON Web Tokens无疑是一种很好的方式。因为 JWT 可以被签名，例如，用公钥/私钥对，你可以确定发送人就是它们所说的那个人。另外，由于签名是使用头和有效负载计算的，您还可以验证内容没有被篡改。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172959.png)

-------------------------

#### JWT 是如何工作的

在认证的时候，当用户用他们的凭证成功登录以后，一个JSON Web Token将会被返回。
此后，token就是用户凭证了，你必须非常小心以防止出现安全问题。一般而言，你保存令牌的时候不应该超过你所需要它的时间。

无论何时用户想要访问受保护的路由或者资源的时候，用户代理（通常是浏览器）都应该带上JWT，典型的，通常放在Authorization header中，用Bearer schema。

header应该看起来是这样的：注意 ==Bearer== 后面是有一个空格的
`Authorization: Bearer <token>`

服务器上的受保护的路由将会检查Authorization header中的JWT是否有效，如果有效，则用户可以访问受保护的资源。如果JWT包含足够多的必需的数据，那么就可以减少对某些操作的数据库查询的需要，尽管可能并不总是如此。

如果token是在授权头（Authorization header）中发送的，那么跨源资源共享(CORS)将不会成为问题，因为它不使用cookie。

下面这张图显示了如何获取JWT以及使用它来访问APIs或者资源：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172960.png)

1.  应用（或者客户端）想授权服务器请求授权。例如，如果用授权码流程的话，就是/oauth/authorize
2.  当授权被许可以后，授权服务器返回一个access token给应用
3.  应用使用access token访问受保护的资源（比如：API）

-------------------

#### 基于 Token 的身份认证 与 基于服务器的身份认证的比较

##### 基于服务器的身份认证 例如 session

这种基于服务器的身份认证方式存在一些问题：

*   Sessions : 每次用户认证通过以后，服务器需要创建一条记录保存用户信息，通常是在内存中，随着认证通过的用户越来越多，服务器的在这里的开销就会越来越大。
*   Scalability : 由于Session是在内存中的，这就带来一些扩展性的问题。
*   CORS : 当我们想要扩展我们的应用，让我们的数据被多个移动设备使用时，我们必须考虑跨资源共享问题。当使用AJAX调用从另一个域名下获取资源时，我们可能会遇到禁止请求的问题。
*   CSRF : 用户很容易受到CSRF攻击。

##### 基于Token的身份认证是如何工作的

基于Token的身份认证是无状态的，服务器或者Session中不会存储任何用户信息。没有会话信息意味着应用程序可以根据需要扩展和添加更多的机器，而不必担心用户登录的位置。虽然这一实现可能会有所不同，但其主要流程如下：

1.  用户携带用户名和密码请求访问
2.  服务器校验用户凭据
3.  应用提供一个token给客户端
4.  客户端存储token，并且在随后的每一次请求中都带着它
5.  服务器校验token并返回数据

注意：

1.  每一次请求都需要token
2.  Token应该放在请求header中
3.  我们还需要将服务器设置为接受来自所有域的请求，用 `Access-Control-Allow-Origin: *`

##### JWT和Session的差异

相同点是，它们都是存储用户信息；然而，Session是在服务器端的，而JWT是在客户端的。

服务端存储会话无外乎两种:
一种是将会话标识符存储在数据库，
一种是存储在内存中维持会话.
我想大多数情况下都是基于内存来维持会话，但是这会带来一定的问题，如果系统存在大流量，也就是说若有大量用户访问系统，此时使用基于内存维持的会话则限制了水平扩展，但对基于Token的认证则不存在这样的问题

同时Cookie一般也只适用于单域或子域，如果对于跨域，假如是第三方Cookie，浏览器可能会禁用Cookie，所以也受浏览器限制，但对Token认证来说不是问题，因为其保存在请求头中。

如果我们将会话转移到客户端，也就是说使用Token认证，此时将解除会话对服务端的依赖，同时也可水平扩展，不受浏览器限制

但是与此同时也会带来一定的问题:
一是令牌的传输安全性，对于令牌传输安全性我们可使用HTTPS加密通道来解决.

二是与存储在Cookie中的SessionId相比，JWT显然要大很多，因为JWT中还包含用户信息，所以为了解决这个问题，我们尽量确保JWT中只包含必要的信息（大多数情况下只包含sub以及其他重要信息），对于敏感信息我们也应该省略掉从而防止XSS攻击。JWT的核心在于声明，声明在JWT中是JSON数据，也就是说我们可以在JWT中嵌入用户信息，从而减少数据库负载。

所以综上所述JWT解决了其他会话存在的问题或缺点：

- 更灵活
- 更安全
- 减少数据库往返，从而实现水平可伸缩
- 防篡改客户端声明
- 移动设备上能更好工作
- 适用于阻止Cookie的用户

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172961.png)

--------------------------------

#### .Net Core中使用JWT

服务端中创建token和使用token进行校验

##### 创建Token

引用nuget包 `System.IdentityModel.Tokens.Jwt`

参看示例代码:
``` csharp
var claims = new Claim[]
            {
                new Claim(ClaimTypes.Name, "Jeffcky"),
                new Claim(JwtRegisteredClaimNames.Email, "2752154844@qq.com"),
                new Claim(JwtRegisteredClaimNames.Sub, "D21D099B-B49B-4604-A247-71B0518A0B1C"),
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("1234567890123456"));

            var token = new JwtSecurityToken(
                issuer: "http://localhost:5000",
                audience: "http://localhost:5001",
                claims: claims,
                notBefore: DateTime.Now,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
            );

            var jwtToken = new JwtSecurityTokenHandler().WriteToken(token);
```

如上我们在声明集合中初始化声明时，我们使用了两种方式，一个是使用 ==ClaimTypes== ，一个是 ==JwtRegisteredClaimNames== ，那么这二者有什么区别？以及我们到底应该使用哪种方式更好？或者说两种方式都使用是否有问题呢？针对ClaimTypes则来自命名空间 ==System.Security.Claims== ，而JwtRegisteredClaimNames则来自命名空间 ==System.IdentityModel.Tokens.Jwt==，二者在获取声明方式上是不同的，ClaimTypes是沿袭微软提供获取声明的方式，比如我们要在控制器Action方法上获取上述ClaimTypes.Name的值，此时我们需要F12查看Name的常量定义值是多少，如下：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172962.png)

我们来尝试获取一下name的值
`var sub = User.FindFirst(d => d.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name")?.Value;`
![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172965.png)
没什么问题,那么再来试试 JwtRegisterClaimNames.Sub 的值
`var sub = User.FindFirst(d => d.Type == JwtRegisteredClaimNames.Sub)?.Value;`
![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172966.png)

> 此时我们发现为空没有获取到，这是为何呢？这是因为获取声明的方式默认是走微软定义的一套映射方式，如果我们想要走JWT映射声明，那么我们需要将默认映射方式给移除掉，在对应客户端Startup构造函数中，添加如下代码：
`JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();`

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172967.png)

如果用过并熟悉IdentityServer4的童鞋关于这点早已明了，因为在IdentityServer4中映射声明比如用户Id即（sub）是使用的JWT，也就是说使用的JwtRegisteredClaimNames，此时我们再来获取Sub看看。
![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172968.png)

所以以上对于初始化声明两种方式的探讨并没有用哪个更好，因为对于使用ClaimTypes是沿袭以往声明映射的方式，如果要出于兼容性考虑，可以结合两种声明映射方式来使用。.

接下来我们来看生成签名代码，生成签名是如下代码：
`var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("1234567890123456"));`

如上我们给出签名的Key是1234567890123456，是不是给定Key的任意长度皆可呢，显然不是，关于Key的长度至少是16，否则会抛出如下错误:
![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172969.png)

接下来我们再来看实例化Token的参数，即如下代码：
``` csharp
var token = new JwtSecurityToken(
                issuer: "http://localhost:5000",
                audience: "http://localhost:5001",
                claims: claims,
                notBefore: DateTime.Now,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
            );
```

issuer代表颁发Token的Web应用程序，audience是Token的受理者，如果是依赖第三方来创建Token，这两个参数肯定必须要指定，因为第三方本就不受信任，如此设置这两个参数后，我们可验证这两个参数。要是我们完全不关心这两个参数，可直接使用JwtSecurityToken的构造函数来创建Token，如下：

``` csharp
var claims = new Claim[]
            {
                new Claim(ClaimTypes.Name, "Jeffcky"),
                new Claim(JwtRegisteredClaimNames.Email, "2752154844@qq.com"),
                new Claim(JwtRegisteredClaimNames.Sub, "D21D099B-B49B-4604-A247-71B0518A0B1C"),
                new Claim(JwtRegisteredClaimNames.Exp, $"{new DateTimeOffset(DateTime.Now.AddMilliseconds(1)).ToUnixTimeSeconds()}"),
                new Claim(JwtRegisteredClaimNames.Nbf, $"{new DateTimeOffset(DateTime.Now).ToUnixTimeSeconds()}")
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("1234567890123456"));

            var jwtToken = new JwtSecurityToken(new JwtHeader(new SigningCredentials(key, SecurityAlgorithms.HmacSha256)), new JwtPayload(claims));
```

这里需要注意的是Exp和Nbf是基于Unix时间的字符串，所以上述通过实例化DateTimeOffset来创建基于Unix的时间。到了这里，我们已经清楚的知道如何创建Token

##### 使用Token

引用nuget包 `Microsoft.AspNetCore.Authentication.JwtBear`
在 `Startup`的`ConfigureServices` 中注册如下代码:

``` csharp
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("1234567890123456")),

                    ValidateIssuer = true,
                    ValidIssuer = "http://localhost:5000",

                    ValidateAudience = true,
                    ValidAudience = "http://localhost:5001",

                    ValidateLifetime = true,

                    ClockSkew = TimeSpan.FromMinutes(5)
                };
            });
```

如上述若Token依赖于第三方而创建，此时必然会配置issuer和audience，同时在我方也如上必须验证issuer和audience，上述我们也验证了签名，我们通过设置 `ValidateLifetime`  为true，说明验证过期时间而并非Token中的值，最后设置 `ClockSkew`  有效期为5分钟。对于设置 ClockSkew  默认也是5分钟。

如上对于认证方案我们使用的是 `JwtBearerDefaults.AuthenticationScheme` 即Bearer，除此之外我们也可以自定义认证方案名称，如下：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/JWT-JsonWebToken/2020811/1597125172970.png)

最后别忘记添加认证中间件在Configure方法中，认证中间件必须放在使用MVC中间件之前，如下：
``` csharp
			app.UseAuthentication();

            app.UseMvc(routes =>
            {
                routes.MapRoute(
                    name: "default",
                    template: "{controller=Home}/{action=Index}/{id?}");
            });
```

-----------------------

#### WebAPI中JWT的刷新

什么是刷新令牌呢？刷新访问令牌是用来从身份认证服务器交换获得新的访问令牌，有了刷新令牌可以在访问令牌过期后通过刷新令牌重新获取新的访问令牌而无需客户端通过凭据重新登录，如此一来，既保证了用户访问令牌过期后的良好体验，也保证了更高的系统安全性，同时，若通过刷新令牌获取新的访问令牌验证其无效可将受访者纳入黑名单限制其访问，那么访问令牌和刷新令牌的生命周期设置成多久合适呢？这取决于系统要求的安全性，一般来讲访问令牌的生命周期不会太长，比如5分钟，又比如获取微信的AccessToken的过期时间为2个小时。接下来我将用两张表来演示实现刷新令牌的整个过程，可能有更好的方案，欢迎在评论中提出，学习，学习。我们新建一个 `http://localhost:5000` 的WebApi用于身份认证，再新建一个 `http://localhost:5001` 的客户端,客户端上模拟两个操作,1登录获取token,2调用一个需要授权的接口资源.

接下来我们新建一张用户表（User）和用户刷新令牌表（UserRefreshToken），结构如下：
``` csharp
public class User
    {
        public string Id { get; set; }
        public string Email { get; set; }
        public string UserName { get; set; }

        private readonly List<UserRefreshToken> _userRefreshTokens = new List<UserRefreshToken>();

        public IEnumerable<UserRefreshToken> UserRefreshTokens => _userRefreshTokens;

        /// <summary>
        /// 验证刷新token是否存在或过期
        /// </summary>
        /// <param name="refreshToken"></param>
        /// <returns></returns>
        public bool IsValidRefreshToken(string refreshToken)
        {
            return _userRefreshTokens.Any(d => d.Token.Equals(refreshToken) && d.Active);
        }

        /// <summary>
        /// 创建刷新Token
        /// </summary>
        /// <param name="token"></param>
        /// <param name="userId"></param>
        /// <param name="minutes"></param>
        public void CreateRefreshToken(string token, string userId, double minutes = 1)
        {
            _userRefreshTokens.Add(new UserRefreshToken() { Token = token, UserId = userId, Expires = DateTime.Now.AddMinutes(minutes) });
        }

        /// <summary>
        /// 移除刷新token
        /// </summary>
        /// <param name="refreshToken"></param>
        public void RemoveRefreshToken(string refreshToken)
        {
            _userRefreshTokens.Remove(_userRefreshTokens.FirstOrDefault(t => t.Token == refreshToken));
        }
```

``` csharp
public class UserRefreshToken
    {
        public string Id { get; private set; } = Guid.NewGuid().ToString();
        public string Token { get; set; }
        public DateTime Expires { get; set; }
        public string UserId { get; set; }
        public bool Active => DateTime.Now <= Expires;
    }
```

如上可以看到对于刷新令牌的操作我们将其放在用户实体中，也就是使用EF Core中的Back Fields而不对外暴露。接下来我们将生成的访问令牌、刷新令牌、验证访问令牌、获取用户身份封装成对应方法如下：

``` csharp
/// <summary>
        /// 生成访问令牌
        /// </summary>
        /// <param name="claims"></param>
        /// <returns></returns>
        public string GenerateAccessToken(Claim[] claims)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey));

            var token = new JwtSecurityToken(
                issuer: "http://localhost:5000",
                audience: "http://localhost:5001",
                claims: claims,
                notBefore: DateTime.Now,
                expires: DateTime.Now.AddMinutes(1),
                signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        /// <summary>
        /// 生成刷新Token
        /// </summary>
        /// <returns></returns>
        public string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(randomNumber);
                return Convert.ToBase64String(randomNumber);
            }
        }

        /// <summary>
        /// 从Token中获取用户身份
        /// </summary>
        /// <param name="token"></param>
        /// <returns></returns>
        public ClaimsPrincipal GetPrincipalFromAccessToken(string token)
        {
            var handler = new JwtSecurityTokenHandler();

            try
            {
                return handler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateAudience = false,
                    ValidateIssuer = false,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
                    ValidateLifetime = false
                }, out SecurityToken validatedToken);
            }
            catch (Exception)
            {
                return null;
            }
        }
```

当用户点击登录，访问身份认证服务器，登录成功后我们创建访问令牌和刷新令牌并返回，如下：

``` csharp
[HttpPost("login")]
        public async Task<IActionResult> Login()
        {
            var user = new User()
            {
                Id = "D21D099B-B49B-4604-A247-71B0518A0B1C",
                UserName = "Jeffcky",
                Email = "2752154844@qq.com"
            };

            await context.Users.AddAsync(user);

            var refreshToken = GenerateRefreshToken();

            user.CreateRefreshToken(refreshToken, user.Id);

            await context.SaveChangesAsync();

            var claims = new Claim[]
            {
                new Claim(ClaimTypes.Name, user.UserName),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
            };

            return Ok(new Response() { AccessToken = GenerateAccessToken(claims), RefreshToken = refreshToken });
        }
```

在脚本中我们点击模拟登录发出ajax请求,然后将返回的访问令牌和刷新令牌存储到本地的localStorage中
然后调用一个接口,同时将登录返回的访问令牌设置在请求头重

``` javascript
$('#btn-currentTime').click(function () {
            GetCurrentTime();
        });

        //调用客户端获取当前时间
        function GetCurrentTime() {
            $.ajax({
                type: 'get',
                contentType: 'application/json',
                url: 'http://localhost:5001/api/home',
                beforeSend: function (xhr) {
                    xhr.setRequestHeader('Authorization', 'Bearer ' + getAccessToken());
                },
                success: function (data) {
                    alert(data);
                },
                error: function (xhr) {
                   
                }
            });
        }
```

好了到了这里我们已经实现模拟登录获取访问令牌，并能够调用客户端接口获取到当前时间，同时我们也只是返回了刷新令牌并存储到了本地localStorage中，并未用到。当访问令牌过期后我们需要通过访问令牌和刷新令牌去获取新的访问令牌，对吧。那么问题来了。我们怎么知道访问令牌已经过期了呢？这是其一，其二是为何要发送旧的访问令牌去获取新的访问令牌呢？直接通过刷新令牌去换取不行吗？有问题是好的，就怕没有任何思考，我们一一来解答。我们在客户端添加JWT中间件时，里面有一个事件可以捕捉到访问令牌已过期（关于客户端配置JWT中间件第一节已讲过，这里不再啰嗦），如下：

``` csharp
options.Events = new JwtBearerEvents
                  {
                      OnAuthenticationFailed = context =>
                      {
                          if (context.Exception.GetType() == typeof(SecurityTokenExpiredException))
                          {
                              context.Response.Headers.Add("act", "expired");
                          }
                          return Task.CompletedTask;
                      }
                  };
```

通过如上事件并捕捉访问令牌过期异常，这里我们在响应头添加了一个自定义键act，值为expired，因为一个401只能反映未授权，并不能代表访问令牌已过期。当我们在第一张图中点击【调用客户端获取当前时间】发出Ajax请求时，如果访问令牌过期，此时在Ajax请求中的error方法中捕捉到，我们在如上已给出发出Ajax请求的error方法中继续进行如下补充：


到了这里我们已经解决如何捕捉到访问令牌已过期的问题，接下来我们需要做的则是获取刷新令牌，直接通过刷新令牌换取新的访问令牌也并非不可，只不过还是为了安全性考虑，我们加上旧的访问令牌。接下来我们发出Ajax请求获取刷新令牌，如下：

``` javascript
//获取刷新Token
        function GetRefreshToken(func) {
            var model = {
                accessToken: getAccessToken(),
                refreshToken: getRefreshToken()
            };
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'http://localhost:5000/api/account/refresh-token',
                dataType: "json",
                data: JSON.stringify(model),
                success: function (data) {
                    if (!data.accessToken && !data.refreshToken) {
                        // 跳转至登录
                    } else {
                        saveAccessToken(data.accessToken);
                        saveRefreshToken(data.refreshToken);
                        func();
                    }
                }
            });
        }
```

``` javascript
error: function (xhr) {
                    if (xhr.status === 401 && xhr.getResponseHeader('act') === 'expired') {

                        /* 访问令牌肯定已过期，将当前请求传入获取刷新令牌方法，
                         * 以便获取刷新令牌换取新的令牌后继续当前请求
                        */
                        GetRefreshToken(GetCurrentTime);
                    }
                }
```

接下来则是通过传入旧的访问令牌和刷新令牌调用接口换取新的访问令牌，如下：

``` csharp
/// <summary>
        /// 刷新Token
        /// </summary>
        /// <returns></returns>
        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] Request request)
        {
            //TODO 参数校验

            var principal = GetPrincipalFromAccessToken(request.AccessToken);

            if (principal is null)
            {
                return Ok(false);
            }

            var id = principal.Claims.First(c => c.Type == JwtRegisteredClaimNames.Sub)?.Value;

            if (string.IsNullOrEmpty(id))
            {
                return Ok(false);
            }

            var user = await context.Users.Include(d => d.UserRefreshTokens)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (user is null || user.UserRefreshTokens?.Count() <= 0)
            {
                return Ok(false);
            }

            if (!user.IsValidRefreshToken(request.RefreshToken))
            {
                return Ok(false);
            }

            user.RemoveRefreshToken(request.RefreshToken);

            var refreshToken = GenerateRefreshToken();

            user.CreateRefreshToken(refreshToken, id);

            try
            {
                await context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            var claims = new Claim[]
            {
                new Claim(ClaimTypes.Name, user.UserName),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
            };

            return Ok(new Response()
            {
                AccessToken = GenerateAccessToken(claims),
                RefreshToken = refreshToken
            });
        }
```