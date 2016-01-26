
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:widget="http://www.netvibes.com/ns/">
<head>
<title>我的日志文章</title>
<link rel="icon" type="image/x-icon" href="http://js5.pp.sohu.com.cn/ppp/blog/widgets_1231/entries/ico_widget.gif" />
<meta name="author" content="Yoker.wu" />
<meta name="website" content="http://yoker.sc0826.com" />
<meta name="description" content="获取日志最新内容" />
<meta name="version" content="0.2" />
<meta name="keyword" content="Yoker,C#,Web编程" />
<meta name="debugMode" content="true" />
<widget:preferences>
  <preference type="text" name="SiteURL" label="地址" defaultValue="http://yoker.sc0826.com/"/>
  <preference type="text" name="ListNum" label="数量" defaultValue="8" />
  <preference type="text" name="CatID" label="分类ID" />
  <preference type="list" name="style" label="特性">
    <option label="点击排行" value="top" />
    <option label="评论排行" value="hot" />
    <option label="最近更新" value="last" />
  </preference>
</widget:preferences>
<script type="text/javascript">
<!--
var siteURL = "http://yoker.sc0826.com/";
widget.onRefresh = function() {
	var AjaxURL, ListNum, CatID;
	if (widget.getValue("SiteURL")) {
		siteURL = widget.getValue("SiteURL");
		siteURL = siteURL.lastIndexOf("/")!=siteURL.length-1?siteURL+"/":siteURL;
	}
	AjaxURL = siteURL + "sow/api.asp?a=data";
	if (widget.getValue("ListNum")) {
		AjaxURL += "&ListNum=" + widget.getValue("ListNum");
	}
	if (widget.getValue("CatID")) {
		CatID = widget.getValue("CatID");
		AjaxURL += "&CatID=" + isNaN(CatID)?0:CatID;
	}
	if (widget.getValue("style")) {
		AjaxURL += "&b=" + widget.getValue("style");
	}else{
		AjaxURL += "&b=last";
	}
	AjaxURL=AjaxURL.replace(/&[a-z]+=0/gi,'');
	//widget.log(AjaxURL);
	UWA.Data.getJson(AjaxURL,setBody);
}
var Template = '<div class="rich_list">{loop}';
Template += '<div class="item">';
Template += '<h3><a href="{$url}" target="_blank">{$title}</a></h3>';
Template += '<p class="description">{$description}</p>';
Template += '</div>';
Template += '{/loop}</div>';

function setBody(obj){
	var tpl = str = Template.replace(/.*((\{loop\})(.*)(\{\/loop\})).*/,"$3");
	var ret = '';
	//widget.log(oNode.length);
	for(var i=0;i<obj.length;i++){
		str = tpl.replace(/\{\$url\}/gi,siteURL + "/article.asp?id="+ obj[i].log_ID);
		str = str.replace(/\{\$title\}/gi,obj[i].log_Title);
		str = str.replace(/\{\$description\}/gi,obj[i].log_Intro);
		ret += str;
	}
	widget.setBody(Template.replace(/(\{loop\})(.*)(\{\/loop\})/,ret));
	var CatID;
	if (widget.getValue("CatID")) {
		CatID = widget.getValue("CatID");
	}
	widget.addBody('<div class="more"><a href="'+siteURL+'default.asp'+ (isNaN(CatID)?'':'cateID='+CatID) +'">查看更多>></a></div>');
}

widget.onLoad = function() {
    if (widget.getValue("SiteURL")) {
		var siteURL = widget.getValue("SiteURL");
		UWA.Data.getJson(siteURL + "SOW/api.asp?a=data&b=last&listnum=5",setBody);
	}
}
-->
</script>
</head>

<body>
<p class="description">SOW给了我们这样一个舞台，为什么不让我们的日志也晒到上面来呢？简单的几个步骤，你也可以！</p>
</body>
</html>
