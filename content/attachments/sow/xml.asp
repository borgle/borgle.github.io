<!--#include file="../const.asp" -->
<!--#include file="../common/cache.asp" -->
<!--#include file="../common/function.asp" -->
<!--#include file="../common/ubbcode.asp" -->
<%
Response.Charset = "UTF-8"
Response.Expires=60
Response.Write("<?xml version=""1.0"" encoding=""UTF-8""?>")
Dim Action : Action = Request("a")
If Action <> "data" Then
	Call SOW_API()
	Response.end
End If

'数据调用过程
Response.ContentType="text/xml"
'On Error Resume Next
Set Conn = Server.CreateObject("Adodb.Connection")
Conn.open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Server.MapPath(AccessFile)
If Err Then
	Response.write "<items>Connected Failed!</items>"
	Response.end
End If

getInfo(1) '读取Blog设置信息
Keywords(1)'写入关键字列表
Smilies(1)'写入表情符号

Dim memName

Response.Write "<items>"
Select Case UCase(Request("b"))
	Case "TOP": Call SOW_GetBlogItem("VIEWS")
	Case "HOT": Call SOW_GetBlogItem("COMMS")
	Case "LAST": Call SOW_GetBlogItem("LAST")
	Case Else 
		Response.write "Error Article Style!"
End Select
Response.write "</items>"

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

	Dim RS,DataRows,index
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
	
	For index=LBound(DataRows,2) To UBound(DataRows,2)
		Response.write "<item>"
		Response.write "<log_ID>"& DataRows(0,index) &"</log_ID>"
		Response.write "<log_Title><![CDATA["& DataRows(1,index) &"]]></log_Title>"
		Response.write "<log_Author><![CDATA["& DataRows(2,index) &"]]></log_Author>"
		Response.write "<log_ViewNums>"& DataRows(3,index) &"</log_ViewNums>"
		Response.write "<log_CommNums>"& DataRows(4,index) &"</log_CommNums>"
		Response.write "<log_PostTime>"& DataRows(5,index) &"</log_PostTime>"
		If DataRows(8,index)=0 Then
		Response.write "<log_Intro><![CDATA["& AddSiteURL(UnCheckStr(DataRows(6,index))) &"]]></log_Intro>"
		Response.write "<log_Content><![CDATA["& AddSiteURL(UnCheckStr(DataRows(7,index))) &"]]></log_Content>"
		Else
		Response.write "<log_Intro><![CDATA["& AddSiteURL(UBBCode(DataRows(6,index),Mid(DataRows(9,index),1,1),Mid(DataRows(9,index),2,1),Mid(DataRows(9,index),3,1),Mid(DataRows(9,index),4,1),Mid(DataRows(9,index),5,1))) &"]]></log_Intro>"
		Response.write "<log_Content><![CDATA["& AddSiteURL(UBBCode(DataRows(7,index),Mid(DataRows(9,index),1,1),Mid(DataRows(9,index),2,1),Mid(DataRows(9,index),3,1),Mid(DataRows(9,index),4,1),Mid(DataRows(9,index),5,1))) &"]]></log_Content>"
		End If
		Response.write "<cate_ID>"& DataRows(10,index) &"</cate_ID>"
		Response.write "<cate_Name><![CDATA["& DataRows(11,index) &"]]></cate_Name>"
		Response.write "</item>"
	Next
End Sub

'显示文章可用分类
Function SOW_GetBlogClass()

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
var siteURL = "http://yoker.sc0826.com/"
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
	UWA.Data.getXml(AjaxURL,setBody);
}
var Template = '<div class="rich_list">{loop}';
Template += '<div class="item">';
Template += '<h3><a href="{$url}" target="_blank">{$title}</a></h3>';
Template += '<p class="description">{$description}</p>';
Template += '</div>';
Template += '{/loop}</div>';

function setBody(oXML){
	var tpl = str = Template.replace(/.*((\{loop\})(.*)(\{\/loop\})).*/,"$3");
	var ret = '', oNode = oXML.documentElement.selectNodes("/items/item");
	//widget.log(oNode.length);
	for(var i=0;i<oNode.length;i++){
		var Node = oNode[i];
		str = tpl.replace(/\{\$url\}/gi,siteURL + "/article.asp?id="+ Node.selectSingleNode("log_ID").text);
		str = str.replace(/\{\$title\}/gi,Node.selectSingleNode("log_Title").text);
		str = str.replace(/\{\$description\}/gi,Node.selectSingleNode("log_Intro").text);
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
		UWA.Data.getXml(siteURL + "SOW/api.asp?a=data&b=last&listnum=5",setBody);
	}
}
-->
</script>
</head>

<body>
<p class="description">SOW给了我们这样一个舞台，为什么不让我们的日志也晒到上面来呢？简单的几个步骤，你也可以！</p>
</body>
</html>
<%End Sub%>
