<!--#include file="../const.asp" -->
<!--#include file="../common/cache.asp" -->
<!--#include file="../common/function.asp" -->
<!--#include file="../common/ubbcode.asp" --><%
Response.Charset = "UTF-8"
Response.Expires=60
Dim Action : Action = Request("a")
If Action <> "data" Then
	Response.ContentType="text/xml"
	Response.write "<?xml version=""1.0"" encoding=""UTF-8""?>"
	Call SOW_API()
	Response.end
End If

'数据调用过程
'On Error Resume Next
Set Conn = Server.CreateObject("Adodb.Connection")
Conn.open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Server.MapPath(AccessFile)
If Err Then
	Response.ContentType="text/xml"
	Response.write "<items>Connected Failed!</items>"
	Response.end
End If

getInfo(1) '读取Blog设置信息
Keywords(1)'写入关键字列表
Smilies(1)'写入表情符号

Dim memName

Response.Write "["
Select Case UCase(Request("b"))
	Case "TOP": Call SOW_GetBlogItem("VIEWS")
	Case "HOT": Call SOW_GetBlogItem("COMMS")
	Case "LAST": Call SOW_GetBlogItem("LAST")
	Case Else 
		Response.write "Error Article Style!"
End Select
Response.write "]"

Conn.Close
Set Conn = Nothing

'显示最新文章
Sub SOW_GetBlogItem(Style)
	Dim ListNum,CatID,SQL
	CatID = CheckStr(Request.QueryString("cateID"))
	ListNum = CheckStr(Request.QueryString("ListNum"))
	IF IsInteger(ListNum) = False Then ListNum = 18
	IF IsInteger(CatID) = False Then
		SQL = "SELECT TOP "& ListNum &" L.log_ID,L.log_Title,l.log_Author,L.log_ViewNums,L.log_CommNums,L.log_PostTime,L.log_Intro,L.log_Content,L.log_edittype,L.log_ubbFlags,C.cate_ID,C.cate_Name FROM blog_Content AS L,blog_Category AS C WHERE C.cate_ID=L.log_cateID AND L.log_IsShow=true AND L.log_IsDraft=false and C.cate_Secret=false"
	Else
		SQL = "SELECT top "& ListNum &" L.log_ID,L.log_Title,l.log_Author,L.log_ViewNums,L.log_CommNums,L.log_PostTime,L.log_Intro,L.log_Content,L.log_edittype,L.log_ubbFlags,C.cate_ID,C.cate_Name FROM blog_Content AS L,blog_Category AS C WHERE log_cateID="&CatID&" AND C.cate_ID=L.log_cateID AND L.log_IsShow=true AND L.log_IsDraft=false and C.cate_Secret=false"
	End If
	Select Case UCase(Style)
		Case "VIEWS" : SQL = SQL & " ORDER BY log_ViewNums DESC"
		Case "COMMS" : SQL = SQL & " ORDER BY log_CommNums DESC"
		Case Else :	SQL = SQL & " ORDER BY log_PostTime DESC"
	End Select

	Dim RS,DataRows
	Set Rs = Conn.Execute(SQL)
	If Not Rs.Eof Then
		DataRows = Rs.getRows()
	Else
		ReDim DataRows(0,0)
	End IF
	RS.close
	set RS=Nothing
	
	If UBound(DataRows,1)=0 Then
		Response.Write "No Data"
		Exit Sub
	End If
	dim json,splitstr,index
	For index=LBound(DataRows,2) To UBound(DataRows,2)
		json = json &splitstr& "{"
		json = json & "log_ID:'"& DataRows(0,index) &"',"
		json = json & "log_Title:'"& SOW_FormatToJs(DataRows(1,index)) &"',"
		json = json & "log_Author:'"& SOW_FormatToJs(DataRows(2,index)) &"',"
		json = json & "log_ViewNums:'"& DataRows(3,index) &"',"
		json = json & "log_CommNums:'"& DataRows(4,index) &"',"
		json = json & "log_PostTime:'"& DataRows(5,index) &"',"
		If DataRows(8,index)=0 Then
		json = json & "log_Intro:'"& SOW_FormatToJs(AddSiteURL(UnCheckStr(DataRows(6,index)))) &"',"
		json = json & "log_Content:'"& SOW_FormatToJs(AddSiteURL(UnCheckStr(DataRows(7,index)))) &"',"
		Else
		json = json & "log_Intro:'"& SOW_FormatToJs(AddSiteURL(UBBCode(DataRows(6,index),Mid(DataRows(9,index),1,1),Mid(DataRows(9,index),2,1),Mid(DataRows(9,index),3,1),Mid(DataRows(9,index),4,1),Mid(DataRows(9,index),5,1)))) &"',"
		json = json & "log_Content:'"& SOW_FormatToJs(AddSiteURL(UBBCode(DataRows(7,index),Mid(DataRows(9,index),1,1),Mid(DataRows(9,index),2,1),Mid(DataRows(9,index),3,1),Mid(DataRows(9,index),4,1),Mid(DataRows(9,index),5,1)))) &"',"
		End If
		json = json & "cate_ID:'"& DataRows(10,index) &"',"
		json = json & "cate_Name:'"& SOW_FormatToJs(DataRows(11,index)) &"'"
		json = json & "}"
		splitstr = ","
	Next
	Response.write json
End Sub

'显示文章可用分类
Function SOW_GetBlogClass()

End Function

Function SOW_FormatToJs(str)
	str = Replace(str,"\","\\")
	str = Replace(str,"/","\/")
	str = Replace(str,"'","\'")
	str = Replace(str,vbcrlf,"")
	str = Replace(str,vbcr,"")
	str = Replace(str,vblf,"")
	SOW_FormatToJs = str
End Function

Function AddSiteURL(ByVal Str)
	If IsNull(Str) Then
		AddSiteURL = "" : Exit Function 
	End If
	Dim re
	Set re=new RegExp
	With re
		.IgnoreCase =True
		.Global=True
		.Pattern="<img (.*?)src=""(?!(http|https)://)(.*?)"""
		str = .replace(str,"<img $1src=""" & SiteURL & "$3""")
		.Pattern="<a (.*?)href=""(?!(http|https|ftp|mms|rstp)://)(.*?)"""
		str = .replace(str,"<a $1href=""" & SiteURL & "$3""")
	End With
	Set re=Nothing
	AddSiteURL=Str
End Function
%>




<% Sub SOW_API() %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:widget="http://www.netvibes.com/ns/">
<head>
<title>开放模块</title>
<link rel="icon" type="image/x-icon" href="http://js5.pp.sohu.com.cn/ppp/blog/widgets_1231/entries/ico_widget.gif" />
<meta name="author" content="Yoker.wu" />
<meta name="website" content="http://yoker.sc0826.com" />
<meta name="description" content="给PJblog中的日志插上SOW翅膀，让她飞上SoHu Blog!" />
<meta name="version" content="0.70" />
<meta name="keyword" content="Yoker.Wu,C#,Web编程,PjBlog" />
<meta name="screenshot" content="http://yoker.sc0826.com/sow/screenshot.jpg" />
<meta name="thumbnail" content="http://yoker.sc0826.com/sow/thumbnail.jpg" />
<meta name="debugMode" content="true" />
<widget:preferences>
  <preference type="text" name="SiteURL" label="地址" />
  <preference type="text" name="ListNum" label="数量" defaultValue="8" />
  <preference type="text" name="CatID" label="分类ID" />
  <preference type="list" name="property" label="特性">
    <option label="点击排行" value="top" />
    <option label="评论排行" value="hot" />
    <option label="最近更新" value="last" />
  </preference>
  <preference type="list" name="style" label="样式">
    <option label="标题列表" value="1" />
    <option label="标题+简介列表" value="2" />
    <option label="自制模板" value="0" />
  </preference>
</widget:preferences>
<script type="text/javascript">
<!--
var siteURL = "http://yoker.sc0826.com/";
var Template = [
'<ul class="text_list">{loop}<li>自制模板，后续开放中。。。</li>{/loop}</ul>',
'<ul class="text_list">{loop}<li><a href="{$url}" target="_blank" title="发表于:{$timstamp}">{$title}</a></li>{/loop}</ul>',
'<div class="rich_list">{loop}<div class="item"><h3><a href="{$url}" target="_blank" title="发表于:{$timstamp}">{$title}</a></h3><p class="description">{$description}</p></div>{/loop}</div>'
];

function LoadData(){
	var AjaxURL, ListNum = 18, CatID = 0;
	if (widget.getValue("SiteURL")) {
		siteURL = widget.getValue("SiteURL");
		siteURL = siteURL.lastIndexOf("/")!=siteURL.length-1?siteURL+"/":siteURL;
	}else{ return; }
	AjaxURL = siteURL + "sow/api.asp?a=data";
	if (widget.getValue("ListNum")) {
		ListNum = widget.getValue("ListNum");
	}
	AjaxURL += "&ListNum=" + (isNaN(ListNum)?'18':ListNum);
	//widget.log(AjaxURL);
	if (widget.getValue("CatID")) {
		CatID = widget.getValue("CatID");
	}
	AjaxURL += "&CatID=" + (isNaN(CatID)?'0':CatID);
	//widget.log(AjaxURL);
	if (widget.getValue("property")) {
		AjaxURL += "&b=" + widget.getValue("property");
	}else{
		AjaxURL += "&b=last";
	}
	//widget.log(AjaxURL);
	//widget.log(AjaxURL.replace(/.*(&b=([a-z]+)).*/gi,'$2'));
	switch(AjaxURL.replace(/.*(&b=([a-z]+)).*/gi,'$2')){
		case 'top' : widget.setTitle('点击排行榜');break;
		case 'hot' : widget.setTitle('评论排行榜');break;
		case 'last' : widget.setTitle('最新日志文章');break;
		default:widget.setTitle('我的日志');
	}
	AjaxURL=AjaxURL.replace(/&[a-z]+=0/gi,'');
	//widget.log(AjaxURL);
	UWA.Data.getJson(AjaxURL,setBody);
}

function setBody(obj){
	var style = 1;
	if (widget.getValue("style")){
		style = widget.getValue("style");
		style = isNaN(style)?2:style;
	}
	var tpl = str = Template[style].replace(/.*((\{loop\})(.*)(\{\/loop\})).*/,"$3");
	//widget.log(tpl);
	var ret = '';
	//widget.log(obj.toString());
	for(var i=0;i<obj.length;i++){
		str = tpl.replace(/\{\$url\}/gi,siteURL + "/article.asp?id="+ obj[i].log_ID);
		str = str.replace(/\{\$timstamp\}/gi,obj[i].log_PostTime);
		str = str.replace(/\{\$title\}/gi,obj[i].log_Title);
		str = str.replace(/\{\$description\}/gi,obj[i].log_Intro);
		ret += str;
	}

	widget.setBody(Template[style].replace(/(\{loop\})(.*)(\{\/loop\})/,ret));
	var CatID;
	if (widget.getValue("CatID")) {
		CatID = widget.getValue("CatID");
	}
	widget.addBody('<div class="more"><a href="'+siteURL+'default.asp'+ (isNaN(CatID)?'':'?cateID='+CatID) +'">查看更多>></a></div>');
}

widget.onRefresh = LoadData;
widget.onLoad = function(){LoadData();}

-->
</script>
</head>

<body>
<p class="description">　　既然SOW给了我们这样一个舞台，让我们给PJblog中的日志插上SOW翅膀，让她飞上SoHu Blog！</p>
<p class="description">　　首先到<a href="http://yoker.sc0826.com/article.asp?id=355" target="_blank">这里</a>下载<b style="color:blue">SOW翅膀包</b>！然后上传到自己PjBlog程序根目录，在SOHU Blog上添加好“<a href="http://ow.blog.sohu.com/widget/399">开放模块</a>”，并点击模块右上角设置“<font color="#ff0000">地址</font>”参数为你的<b>PjBlog地址</b>就可开始使用了!</p>
</body>
</html>
<%End Sub%>
