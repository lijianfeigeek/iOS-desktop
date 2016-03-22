# iOS-desktop
![](http://7xraw1.com1.z0.glb.clouddn.com/SpeedyDesktop.gif)

之前的一片博客，忘记发demo，补上。

原文地址：http://lijianfei.sinaapp.com/?p=711

cocoachina：http://www.cocoachina.com/ios/20150827/13243.html

***

Safari有一个“添加至屏幕”的功能，其实就是在桌面上添加了一个网页书签，App可以使用这个功能来实现创建桌面快捷方式。

## 一、运用基本技术点
1. JavaScript
2. Data URI Schema
3. Socket基本知识
4. Base64编码

## 基本原理
程序内部创建一个简单的Web站点，通过这个站点调用Safari，站点将自定义的Html页面返回给Safari，此时利用Safari的“添加至主屏幕”功能，将自定义的Html制作成桌面书签，当用户点击桌面图标时，则运行自定义的Javascript来进行跳转至App。

## 三、什么是 data URI scheme？
假设你有以下的图像：

A .png

把它在网页上显示出来的标准方法是：

`<img src=”http://sjolzy.cn/images/A.png”/>`
这 种取得资料的方法称为 http URI scheme ，同样的效果使用 data URI scheme 可以写成：

`<img src=”data:image/png;base64,iVBO…” />`换句话说我们把图像档案的内容内置在 HTML 档案中，节省了一个 HTTP 请求。

网页优化的一大首要任务是减少HTTP 请求 (http request) 的次数，例如通过合并多个JS文件，合并CSS样式文件。除此之外，还有一个data URL 的密技，让我们直接把图像的内容崁入网页里面，这个密技的官方名称是 data URI schema 。

Data URI scheme 的语法
我们来分析一下这句 img 标签的语法：

`<img src=”data:image/png;base64,iVBOR….>`它包含一下部分：

data – 取得数据的协定名称

image/png – 数据类型名称

base64 – 数据的编码方法

iVBOR…. – 编码后的数据

: , ; – data URI scheme 指定的分隔符号

## 四、什么是 Base64 编码？

简单地说它把一些 8-bit 数据翻译成标准 ASCII 字符，往上有很多免费的 base64 编码和解码的工具。

## 五、Socket基本知识
自行脑补，这里我用了iOS中很棒的一个HttpServer第三方框架[CocoaHttpServer](https://github.com/robbiehanson/CocoaHTTPServer)。

## 六、实现
上面基本知识介绍完毕，下面开始撸代码。

iOS 的代码很简单，我们使用CocoaHttpServer创建一个本地的站点即可。

```
- (IBAction)action:(id)sender
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    _httpServer = [[HTTPServer alloc] init];
    [_httpServer setType:@"_http._tcp."];
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
 
    DDLogInfo(@"Setting document root: %@", webPath);
 
    [_httpServer setDocumentRoot:webPath];
 
    [self startServer];
}
```

```
- (void)startServer
{
    // Start the server (and check for problems)
 
    NSError *error;
    if([_httpServer start:&error])
    {
        DDLogInfo(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
 
        // open the url.
        NSString *urlStrWithPort = [NSString stringWithFormat:@"http://localhost:%d",[_httpServer listeningPort]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStrWithPort]];
    }
    else
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
}
```

ok。核心代码来了…

创建一个index.html文件，里面内容如下：

```
<!DOCTYPE html>
<html>
<head lang="en">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="refresh" content="0;URL = *">
</head>
<body>
 
</body>
</html>
```

什么意思呢？

`<meta http-equiv="refresh" content="0; url=">`

页面定期刷新，如果加url的，则会重新定向到指定的网页，content后面跟的是时间（单位秒），把这句话加到指定网页的<head></head>里一般也用在实时性很强的应用中，需要定期刷新。

这个文件放在文件夹WEB目录下，**切记这个文件在工程中是实体文件夹，folder references**。

接下来我们会再创建一个content.html的文件，但是这个文件不会放在WEB文件夹内，而是转换成data URI schema  放在上面的重定向到指定网页的位置。

以下是我demo的content.html文件的内容：

```
<!DOCTYPE html>
<html>
<head>
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta content="text/html charset=UTF-8" http-equiv="Content-Type" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
 
    <link rel='apple-touch-icon' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADcAAAA3CAAAAACNsI2aAAAACXBIWXMAAAB5AAAAeQBPsriEAAAB6ElEQVR42rVWO46EMAzNadAcY3vaOQMXoXcXKZehS8NpqNxamw8JxDYra1Zjhgge9jhx/By7bYvtl4Y8Qn+tEjty6WxuQ0KkfOM5wJEeEkT1bsigU+xGQV+QfZ2ned0LAkLnyQ4XV2XB/k+jXdTs8Mc1+UlvQehEt5Fit7hLFsUfqfOk3d1lJ9VO+qN1sFvJm+IScB7s3uo8ZVzC8RrsXjIuqp2n0d+sxFNbHxCw9cF34yn2L5jyJWndIprzRfqLpvw0+6PCh1fjgxpP5NL4VzlYEa6zOYDgzyvk0cMbykMek6THipSXAD5/BKh8H/3JGZTxPgM9Px9WDL0CkM1ORJie48nsWAXQ8kW1YxlknKfIWJs/EBXgoZ6Jf2KMNMYz4FgBJjTGkxR/H67vm/H8eP9ShlyRqfli24c0svy0zLNXgOkNtQJEle/P/MPOv8T3TGZIZIbO7sL7BMON74nkuQqUj4XvnMvwiNCBjO+yev2NVDtZLeX5rvD9lu0zauxW+a6dBvJ8H5Gyfzz3wIBkO57rYECyHeeWF+xW+YcT47Jkdzi4TpT+lPNdIv9Z34fxNOxf0PhO91yw5MuMen56AxLPOtG7W9T63SCQ2k9Uol1so3bVnrog2JTyU57n1bb37n3s5s8Of5RfsaTdSlfuyUAAAAA8dEVYdGNvbW1lbnQAIEltYWdlIGdlbmVyYXRlZCBieSBHTlUgR2hvc3RzY3JpcHQgKGRldmljZT1wbm1yYXcpCvqLFvMAAABKdEVYdHNpZ25hdHVyZQA4NWUxYWU0YTJmYmE3OGVlZDRmZDhmMGFjZjIzNzYwOWU4NGY1NDk2Y2RlMjBiNWQ3NmM5Y2JjMjk4YzRhZWJjJecJ2gAAAABJRU5ErkJggg=='>
    <title>李剑飞的快捷方式</title>
 
</head>
 
<body bgcolor="#ffffff">
    <a href="com.lijianfei.demo://ABCD" id="qbt" style="display: none"></a>
    <span id="msg"></span>
</body>
 
<script>
    if (window.navigator.standalone == true)
    {
        var lnk = document.getElementById("qbt")
        var evt = document.createEvent('MouseEvent')
        evt.initMouseEvent('click')
        lnk.dispatchEvent(evt)
    }
    else
    {
        document.getElementById("msg").innerHTML='<div style="font-size:12px"> 添加快捷方式 </div>'
    }
</script>
</html>
```

相信稍微做过前端开发的同学们都看懂是什么意思了，我这里大概讲一下。

上面这那几个meta标签其实就是为了设置样式，[更多详情请看苹果官方文档关于这部分的介绍](https://developer.apple.com/library/ios/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html)。

下面这个link就是快捷方式的启动图标，这个图片是经过Base64编码的。

再下面的title就是快捷方式的名称。

接下来body标签中的超链接就是我demo的URL Schemes,通过URL Schemes来跳转进我们的App。下面的span标签用来占位，我们使用JS代码来控制它的显示内容。

这段JS代码的意思就是检测iOS WebApp是否运行在全屏模式。

iOS上的Safari浏览器可以让Web应用程序全屏显示，以取得类似本地应用的显示效果。但是这需要用户把Web应用程序的图标添加到主屏幕才可以。作为开发者，为了更好的显示效果，我们可能希望自己开发的Web应用程序在非全屏状态下运行时提示用户把Web应用程序的图标添加到主屏幕。要检测Web应用程序当前是否运行在全屏状态，只要检测window.navigator.standalone是否为true就可以了，如果这个属性为true则表示Web应用程序当前运行在全屏状态，否则运行在非全屏状态。检测到Web应用程序运行在非全屏状态时就可以提示用户把Web应用程序的图标添加到主屏幕。

最后再把content.html里的这段代码通过[这个网站](http://software.hixie.ch/utilities/cgi/data/data)转换成data URI schema 放在index.html中，就完成了。


