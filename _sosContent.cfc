<cfcomponent name="sosContent" displayName="sosContent" output="false">
	
	<cffunction name="addContent" access="public" output="false">
		<cfargument name="name" required=true>
		<!--- Default should be "mainBody", but must be declared by user --->
		<cfargument name="content" required="true">
		<cfargument name="position" default="">
		<cfargument name="nest" default="true" required="false">
		<cfargument name="cache" default="false" required="false">
		<cfscript>
		var contentToAdd = structNew();
		
		structAppend(contentToAdd,arguments);
		structDelete(contentToAdd,"name");
		structDelete(contentToAdd,"position");
		if (NOT structKeyExists(variables,"content")) {
			variables.content = structNew();
		}
		
		if (NOT structKeyExists(variables.content,arguments.name)) {
			variables.content[arguments.name] = arrayNew(1);
		}
		if (arguments.position != 'first' AND arguments.position GT arrayLen(variables.content[arguments.name])) {
			arguments.position = 'last';
		}
		if (arguments.position == 'first'){
			arrayPrepend(variables.content[arguments.name],contentToAdd);
		} else if (isNumeric(arguments.position)) {
			arrayInsertAt(variables.content[arguments.name],arguments.position,contentToAdd);
		} else {
			arrayAppend(variables.content[arguments.name],contentToAdd);
		}
		</cfscript>
	</cffunction>

	<cffunction name="getContent" access="public" output="false">
		<cfargument name="name" required=true>
		
		<cfreturn variables.content[arguments.name]>
	</cffunction>

	<cffunction name="getHeadContent" access="public" output="false">
		<cfset var thisItem = ''>
		<cfset var myReturn = ''>
		<cfset var iArrayElem = 0>
		<cfset paramHeadContent("js")>
		<cfset paramHeadContent("css")>
		<cfloop from="1" to="#arrayLen(variables.headContent.css.item)#" index="iArrayElem">
			<cfset thisItem = variables.headContent.css.item[iArrayElem]>
			<cfif NOT structKeyExists(thisItem,"content")>
				<cfset myReturn = myReturn & '
<link href="#thisItem.src#" rel="stylesheet" type="text/css" />'>
			<cfelse>
				<cfset myReturn = myReturn & "#thisItem.content#
">
			</cfif>
		</cfloop>
		<cfset iArrayElem = 0>
		<cfloop from="1" to="#arrayLen(variables.headContent.js.item)#" index="iArrayElem">
			<cfset thisItem = variables.headContent.js.item[iArrayElem]>
			<cfif NOT structKeyExists(thisItem,"content")>
				<cfset myReturn = myReturn & '<script type="text/javascript" language="javascript" src="#thisItem.src#"></script>
'>
			<cfelse>
				<cfset myReturn = myReturn & "#thisItem.content#
">
			</cfif>
		</cfloop>
		<cfset variables.headContent = structNew()>
		<cfhtmlHead text="#myReturn#" >
		<cfreturn myReturn>
	</cffunction>
	
	<cffunction name="setSimpleContent" access="public" output="false">
		<cfargument name="name">
		<cfargument name="value" default="">
		<cfparam name="variables.simpleContent" default="#structNew()#">
		<cfset variables.simpleContent[arguments.name] = arguments.value>
	</cffunction>
	
	<cffunction name="getSimpleContent" access="public" output="false">
		<cfargument name="name">
		<cfparam name="variables.simpleContent" default="#structNew()#">
		<cfparam name="variables.simpleContent[arguments.name]" default="">
		
		<cfreturn variables.simpleContent[arguments.name]>
	</cffunction>
	
	<cffunction name="paramSimpleContent" access="public" output="false">
		<cfargument name="name">
		<cfargument name="value" default="">
		<cfparam name="variables.simpleContent" default="#structNew()#">
		<cfparam name="variables.simpleContent[arguments.name]" default="#arguments.value#">
		
		<cfreturn variables.simpleContent[arguments.name]>
	</cffunction>
	
	<cffunction name="addHeadContent" access="public" output="false">
		<cfargument name="position" required="false" default="last">
		<cfargument name="before" required="false" default="none">
		<cfargument name="after" required="false" default="all">
		<cfargument name="type" required="false">
		<cfargument name="id" required="false" default="#createUUID()#">
		<cfargument name="content" required="false" default="">
		<cfargument name="src" required="false" default="#arguments.id#">
		<cfscript>
			var thisInclude = structNew();
			var thisPosition = 1;
			var delimiter = chr(8);
			var doAppend = true;
			paramHeadContent(arguments.type);
			thisInclude.src = arguments.src;
			if(arguments.src NEQ arguments.id) {
				arguments.id = arguments.src;
			} else if (arguments.content NEQ ''){
				thisInclude.content = arguments.content;
			} else {
				doAppend = false;
			}
			thisPosition = getPosition(arguments.before,arguments.after,arguments.position,arguments.type);
			if (doAppend) {
				if (NOT listFind(variables.headContent[arguments.type].src,arguments.src,delimiter)) {
					if (thisPosition EQ 'append') {
						arrayAppend(variables.headContent[arguments.type].item,thisInclude);
						variables.headContent[arguments.type].key = listAppend(variables.headContent[arguments.type].key,arguments.id,delimiter);
					} else {
						if (thisPosition EQ 1) {
							arrayPrepend(variables.headContent[arguments.type].item,thisInclude);
							variables.headContent[arguments.type].key = listPrepend(variables.headContent[arguments.type].key,arguments.id,delimiter);
						} else {
							if (listLen(variables.headContent[arguments.type].key,delimiter) LTE thisPosition) {
								arrayAppend(variables.headContent[arguments.type].item,thisInclude);
								variables.headContent[arguments.type].key = listAppend(variables.headContent[arguments.type].key,arguments.id,delimiter);
							} else {
								arrayInsertAt(variables.headContent[arguments.type].item,thisPosition,thisInclude);
								variables.headContent[arguments.type].key = listInsertAt(variables.headContent[arguments.type].key,thisPosition,arguments.id,delimiter);
							}
						}
					}
					if (arguments.content EQ '') {
						variables.headContent[arguments.type].src = listAppend(variables.headContent[arguments.type].src,arguments.src,delimiter);
					}
						
				}		
			} else {
			}
			return arguments.id;
		</cfscript>
	</cffunction>
	
	<cffunction name="getPosition" access="private" output="false">
		<cfargument name="before">
		<cfargument name="after">
		<cfargument name="position">
		<cfargument name="type">
		<cfscript>
			var thisPosition = arrayLen(variables.headContent[arguments.type].item);
			var currentPOS = 1;
			var iListItem = 1;
			var delimiter = chr(8);
			if (arguments.before EQ 'none' AND arguments.after EQ 'all') {
				if (arguments.position EQ 'first' OR arguments.position LT 1) {
					thisPosition = 1;
				} else if (arguments.position EQ 'last' OR arguments.position EQ '' OR arguments.position gt arrayLen(variables.headContent[arguments.type].item)) {
					thisPosition = 'append';
				} else {
					thisPosition = arguments.position;
				}
			} else {
				if (arguments.before NEQ 'none') {
					if (listLen(arguments.before) GT 1) {
						for (iListItem = 1;iListItem LTE listLen(arguments.before); iListItem=iListItem + 1) {
							currentPos = listFindNoCase(variables.headContent[arguments.type].key,listGetAt(arguments.before,iListItem),delimiter);
							if (currentPos LT thisPosition) {
								thisPosition = currentPos + 1;
							}
						}
					} else {
						thisPosition = listFindNoCase(variables.headContent[arguments.type].key,arguments.before,delimiter);
					}
				} else if (arguments.after NEQ 'all') {
					if (listLen(arguments.after) GT 1) {
						for (iListItem = 1;iListItem LTE listLen(arguments.after); iListItem=iListItem + 1) {
							currentPos = listFindNoCase(variables.headContent[arguments.type].key,listGetAt(arguments.after,iListItem),delimiter);
							if (currentPos LTE thisPosition) {
								thisPosition = currentPos + 1;
							}
						}
					} else {
						thisPosition = listFindNoCase(variables.headContent[arguments.type].key,arguments.after,delimiter) + 1;
					}
				}
			}
			if (thisPosition LT 1) {
				thisPosition = 'append';
			}
			return thisPosition;
		</cfscript>
	</cffunction>
		
	<cffunction name="_dump" access="public" output="true">
		<cfargument name="var">
		<cfargument name="label" required="false" default="">
		<cfargument name="expand" default="true" required="false">
		<cfargument name="abort" default="false" required="false">
		<cfscript>
			if ( isSimpleValue(arguments.var)) {
				writeOutput("<br/> " & arguments.label & ": ");
			}
		</cfscript>
		<cfdump var="#arguments.var#" label="#arguments.label#" expand="#arguments.expand#">
		<cfif arguments.abort>
			<cfabort>
		</cfif>
	</cffunction>
	
	<cffunction name="paramHeadContent" access="public" output="false">
		<cfargument name="type">
		<cfscript>
		if (NOT structKeyExists(variables,"headContent")) {
			variables.headContent = structNew();
		}
		if (NOT structKeyExists(variables.headContent,arguments.type)) {
			variables.headContent[arguments.type] = structNew();
			variables.headContent[arguments.type].item = arrayNew(1);
			variables.headContent[arguments.type].src = '';
			variables.headContent[arguments.type].key = '';
		}
		</cfscript>
	</cffunction>

	<cffunction name="setTemplate" access="public" output="false">
		<cfargument name="template" required="true">
		<cfargument name="setting" required="true">
		<cfset VARIABLES.template[ARGUMENTS.template] = ARGUMENTS.setting>
	</cffunction>
	
	<cffunction name="getTemplate" access="public" output="false">
		<cfargument name="template" required="true">
		
		<cfparam name="VARIABLES.template" default="#structNew()#">
		<cfscript>
		if(structKeyExists(VARIABLES.template,ARGUMENTS.template)){
			return VARIABLES.template[ARGUMENTS.template];
		} else {
			return "default";
		}
		</cfscript>
	</cffunction>

</cfcomponent>