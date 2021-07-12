<%@page import="test.users.dao.UsersDao"%>
<%@page import="test.study.dao.StudyBookMarkDao"%>
<%@page import="test.study.dto.StudyBookMarkDto"%>
<%@page import="test.study.dto.StudyLikeDto"%>
<%@page import="test.study.dao.StudyLikeDao"%>
<%@page import="java.util.List"%>
<%@page import="test.study.dao.StudyCommentDao"%>
<%@page import="test.study.dto.StudyCommentDto"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="test.study.dto.StudyDto"%>
<%@page import="test.study.dao.StudyDao"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	int num=Integer.parseInt(request.getParameter("num"));
	StudyDao.getInstance().addViewCount(num);
		
	String category=request.getParameter("category");
	String keyword=request.getParameter("keyword");
	String condition=request.getParameter("condition");
	if(keyword==null){
		keyword="";
		condition="";
	}
	if(category==null){
		category="whole";
		
	}
	String encodedK=URLEncoder.encode(keyword);
	
	StudyDto dto=new StudyDto();
	dto.setNum(num);
	
	if(category.equals("whole")&&!keyword.equals("")){
		if(condition.equals("title")){
			dto.setTitle(keyword);
			dto=StudyDao.getInstance().getDataT(dto);
			
		}else if(condition.equals("nick")){
			dto.setNick(keyword);
			dto=StudyDao.getInstance().getDataN(dto);
			
		}else if(condition.equals("title_content")){
			dto.setTitle(keyword);
			dto.setContent(keyword);
			dto=StudyDao.getInstance().getDataTC(dto);
		}
	}else if(category.equals("whole")&&keyword.equals("")){
		dto=StudyDao.getInstance().getData(dto);
	}else if(keyword.equals("")&&!category.equals("whole")){
		dto.setCategory(category);
		dto=StudyDao.getInstance().getDataC(dto);
	}else if(!category.equals("whole")&&!keyword.equals("")){
		if(condition.equals("title")){
			dto.setCategory(category);
			dto.setTitle(keyword);
			dto=StudyDao.getInstance().getDataTCa(dto);
			
		}else if(condition.equals("nick")){
			dto.setCategory(category);
			dto.setNick(keyword);
			dto=StudyDao.getInstance().getDataNCa(dto);
			
		}else if(condition.equals("title_content")){
			dto.setCategory(category);
			dto.setTitle(keyword);
			dto.setContent(keyword);
			dto=StudyDao.getInstance().getDataTCCa(dto);
		}
	}
	
	String id=(String)session.getAttribute("id");
	
	StudyLikeDto dtoL=new StudyLikeDto();
	dtoL.setNum(num);
	dtoL.setId(id);
	int count=StudyLikeDao.getInstance().isExist(dtoL);
	if(count<1){
		StudyLikeDao.getInstance().insert(dtoL);
	}
	
	dtoL=StudyLikeDao.getInstance().getData(dtoL);
	
	
	StudyBookMarkDto dtoS=new StudyBookMarkDto();
	dtoS.setNum(num);
	dtoS.setId(id);
	int counting=StudyBookMarkDao.getInstance().isExist(dtoS);
	if(counting<1){
	   StudyBookMarkDao.getInstance().insert(dtoS);
	}
	
	dtoS=StudyBookMarkDao.getInstance().getData(dtoS);
	

	 final int PAGE_ROW_COUNT=10;
	 
	 int pageNum=1;
	 

	 int startRowNum=1+(pageNum-1)*PAGE_ROW_COUNT;
	 int endRowNum=pageNum*PAGE_ROW_COUNT;
	

	StudyDto dto2=StudyDao.getInstance().getData(num);
	

	StudyCommentDto commentDto=new StudyCommentDto();
	commentDto.setRef_group(num);
	

	commentDto.setStartRowNum(startRowNum);
	commentDto.setEndRowNum(endRowNum);
	
	List<StudyCommentDto> commentList=
			StudyCommentDao.getInstance().getList(commentDto);
	
	int totalRow=StudyCommentDao.getInstance().getCount(num);
	int totalPageCount=(int)Math.ceil(totalRow/(double)PAGE_ROW_COUNT);
	
	int likeCount=StudyLikeDao.getInstance().getCount(num);
	
	
	boolean isLike=false;
	if(dtoL.getLiked().equals("yes")){
		isLike=true;
	}
	
	int markCount=StudyBookMarkDao.getInstance().getCount(num);
	   
	boolean isMark=false;
	if(dtoS.getBookmark().equals("yes")){
	   isMark=true;
	}
	
	String grade=UsersDao.getInstance().getGrade(dto.getWriter());
	String grade_mark=null;
	if(grade.equals("child")){
		grade_mark="♠";
	}else if(grade.equals("student")){
		grade_mark="♣";
	}else if(grade.equals("adult")){
		grade_mark="★";
	}
	
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DreamAdult</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/main.css" />
<style>
   .content{
      border: 1px dotted gray;
   }
   

   .profile-image{
      width: 50px;
      height: 50px;
      border-radius: 50%;
   }
	.detail-profile-image{
      width: 30px;
      height: 30px;
      border-radius: 50%;
   }
   .comments ul{
      padding: 0;
      margin: 0;
      list-style-type: none;
   }
   .comments dt{
      margin-top: 5px;
   }
   .comments dd{
      margin-left: 50px;
   }
   .comment-form textarea, .comment-form button{
      float: left;
   }
   .comments li{
      clear: left;
   }
   .comments ul li{
      border-top: 1px solid #888;
   }
   .comment-form textarea{
      width: 84%;
      height: 100px;
   }
   .comment-form button{
      width: 14%;
      height: 100px;
   }

   .comments .comment-form{
      display: none;
   }

   .comments li{
      position: relative;
   }
   .comments .reply-icon{
      position: absolute;
      top: 1em;
      left: 1em;
      color: red;
   }
   pre {
     display: block;
     padding: 9.5px;
     margin: 0 0 10px;
     font-size: 13px;
     line-height: 1.42857143;
     color: #333333;
     word-break: break-all;
     word-wrap: break-word;
     background-color: #f5f5f5;
     border: 1px solid #ccc;
     border-radius: 4px;
   }      
   .loader{

   		text-align:center;
   		display:none;
   }
   .loader svg{
   		animation: rotateAni 1s ease-out infinite;
   }
   
   @keyframes rotateAni{
   		0%{
   			transform: rotate(0deg);
   		}
   		100%{
   			transform: rotate(360deg);
   		}
   }
   a{
   	 text-decoration:none;
   }
   .grade{
   		color:#777;
   }
</style>
</head>
<body>
<jsp:include page="../../include/navber.jsp"><jsp:param value="study" name="thisPage"/></jsp:include>
<div class="detail_page container">
	<h1 class="main-tit">
		학습공부 게시판
	</h1>

   <% if(!keyword.equals("")&&!category.equals("whole")){ %>
      <p>   
      	 <strong><%=category %></strong> 분류,
         <strong><%=condition %></strong> 조건, 
         <strong><%=keyword %></strong> 검색어로 검색된 내용 자세히 보기 
      </p>
   <%}else if(keyword.equals("")&&!category.equals("whole")) {%>
   		<p>
   			<strong><%=category %></strong>로 분류된 내용 자세히 보기
   		</p>
   <%}else if(category.equals("whole")&&!keyword.equals("")) {%>
   		<p>   
         <strong><%=condition %></strong> 조건, 
         <strong><%=keyword %></strong> 검색어로 검색된 내용 자세히 보기 
      	</p>
   <%} %>
	<div class="detail-header">
		<span class="num"><%=dto.getNum() %></span>
		<span class="category"><%=dto.getCategory() %></span>
		<span class="tit"><%=dto.getTitle()%></span>
		<span class="regdate"><%=dto.getRegdate() %></span>
		<ul class="icons-wrap">
			<%if(isMark){ %>
		       <li>
		           <a data-num="<%=num %>" href="javascript:" class="icon-link mark-link">
		    	       	<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-bookmark-check-fill" viewBox="0 0 16 16">
						  <path fill-rule="evenodd" d="M2 15.5V2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v13.5a.5.5 0 0 1-.74.439L8 13.069l-5.26 2.87A.5.5 0 0 1 2 15.5zm8.854-9.646a.5.5 0 0 0-.708-.708L7.5 7.793 6.354 6.646a.5.5 0 1 0-.708.708l1.5 1.5a.5.5 0 0 0 .708 0l3-3z"/>
						</svg>
		            </a>
		       </li>
		   	<%}else{ %>
				<li>
		           	<a data-num="<%=num %>" href="javascript:" class="icon-link mark-link">
			           	<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-bookmark-check" viewBox="0 0 16 16">
						  <path fill-rule="evenodd" d="M10.854 5.146a.5.5 0 0 1 0 .708l-3 3a.5.5 0 0 1-.708 0l-1.5-1.5a.5.5 0 1 1 .708-.708L7.5 7.793l2.646-2.647a.5.5 0 0 1 .708 0z"/>
						  <path d="M2 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v13.5a.5.5 0 0 1-.777.416L8 13.101l-5.223 2.815A.5.5 0 0 1 2 15.5V2zm2-1a1 1 0 0 0-1 1v12.566l4.723-2.482a.5.5 0 0 1 .554 0L13 14.566V2a1 1 0 0 0-1-1H4z"/>
						</svg>
		           	</a>
		        </li>
		    <%} %>
			<%if(isLike){ %>
		         <li>
		          	<a data-num="<%=num %>" href="javascript:" class="icon-link like-link">
		     	      	<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-heart-fill" viewBox="0 0 16 16">
						  <path fill-rule="evenodd" d="M8 1.314C12.438-3.248 23.534 4.735 8 15-7.534 4.736 3.562-3.248 8 1.314z"/>
						</svg>
		        	   	<span class="like-count"><%=likeCount%></span>
		           	</a>
		         </li>
		     <%}else{ %>
		         <li>
		           	<a data-num="<%=num %>" href="javascript:" class="icon-link like-link">
		            	<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-heart" viewBox="0 0 16 16">
						  <path d="m8 2.748-.717-.737C5.6.281 2.514.878 1.4 3.053c-.523 1.023-.641 2.5.314 4.385.92 1.815 2.834 3.989 6.286 6.357 3.452-2.368 5.365-4.542 6.286-6.357.955-1.886.838-3.362.314-4.385C13.486.878 10.4.28 8.717 2.01L8 2.748zM8 15C-7.333 4.868 3.279-3.04 7.824 1.143c.06.055.119.112.176.171a3.12 3.12 0 0 1 .176-.17C12.72-3.042 23.333 4.867 8 15z"/>
						</svg>
		         	  	<span class="like-count"><%=likeCount%></span>
		           	</a>
		         </li>
		     <%} %> 				
		</ul>
	</div>
	<div class="detail-main">
		<p style="text-align:right;">
			<span>
				<%if(UsersDao.getInstance().getData(dto.getWriter()).getProfile()== null){ %>
	                <svg class="detail-profile-image" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
	                	<path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
	                    <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"/>
	                </svg>
	            <%}else{ %>
	            	<img class="detail-profile-image" src="${pageContext.request.contextPath}<%=UsersDao.getInstance().getData(dto.getWriter()).getProfile()%>"/>
	            <%} %>
				<strong><%=dto.getNick()%></strong> <span class="grade">(<%=grade_mark %><%=grade %>) </span>
			</span>
			<span style="margin-left:10px;">조회수 <%=dto.getViewCount() %></span>
		</p>
		<div class="content">
			<%=dto.getContent() %>
		</div>
	</div>


    <div class="order-wrap">
	   	<%if(dto.getPrevNum()!=0){ %>
	      <a class="prev-btn" href="detail.jsp?num=<%=dto.getPrevNum() %>&keyword=<%=encodedK %>&condition=<%=condition%>&category=<%=category%>">
	      	<span>이전글</span>
	      	<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-up-short" viewBox="0 0 16 16">
			  <path fill-rule="evenodd" d="M8 12a.5.5 0 0 0 .5-.5V5.707l2.146 2.147a.5.5 0 0 0 .708-.708l-3-3a.5.5 0 0 0-.708 0l-3 3a.5.5 0 1 0 .708.708L7.5 5.707V11.5a.5.5 0 0 0 .5.5z"/>
			</svg>
			<span><%=StudyDao.getInstance().getData(dto.getPrevNum()).getTitle() %></span>
	      </a>
	   <%} %>
	   <%if(dto.getNextNum()!=0){ %>
	      <a class="next-btn" href="detail.jsp?num=<%=dto.getNextNum() %>&keyword=<%=encodedK %>&condition=<%=condition%>&category=<%=category%>">
	      	<span>다음글</span>
	      	<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-down-short" viewBox="0 0 16 16">
			  <path fill-rule="evenodd" d="M8 4a.5.5 0 0 1 .5.5v5.793l2.146-2.147a.5.5 0 0 1 .708.708l-3 3a.5.5 0 0 1-.708 0l-3-3a.5.5 0 1 1 .708-.708L7.5 10.293V4.5A.5.5 0 0 1 8 4z"/>
			</svg>
			<span><%=StudyDao.getInstance().getData(dto.getNextNum()).getTitle() %></span>
	      </a>
	   <%} %>
   </div>
   <div class="btn-wrap">
		<a class="btn btn-custom-dark" href="<%=request.getContextPath()%>/study/list.jsp">목록보기</a>
		<%if(dto.getWriter().equals(id)) {%>
            <a class="btn btn-custom-dark" href="<%=request.getContextPath()%>/study/private/updateform.jsp?num=<%=dto.getNum()%>">수정</a>
            <a class="btn btn-custom-dark" id="postDelete">삭제</a>
        <%} %>
   </div>


   <div class="comment-wrap">
   		<p>댓글 <strong><%=StudyCommentDao.getInstance().getCount(num) %></strong>개</p>
   		

	   <form class="comment-form insert-form" action="comment_insert.jsp" method="post">
	   		<input type="hidden" name="ref_group" value="<%=num %>" />
	   		<input type="hidden" name="target_nick" value="<%=dto.getNick() %>" />
	   		<textarea name="content"></textarea>
	   		<button type="submit" class="btn btn-custom-blue">등록</button>
	   </form>
	   <div class="comments" style="margin-top:200px;">
	   		<ul>
	   			<%for(StudyCommentDto tmp: commentList){ %>
	   				<%if(tmp.getDeleted().equals("yes")){ %>
	   					<li>삭제된 댓글 입니다.</li>
	   				<%
	   					continue;
	   				}%>
	   				<%if(tmp.getNum()==tmp.getComment_group()) {%>
	   				<li id="reli<%=tmp.getNum()%>">
	   				<%}else{ %>
	   				<li id="reli<%=tmp.getNum()%>" style="padding-left:50px;">
	   					<svg class="reply-icon" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-return-right" viewBox="0 0 16 16">
	                    	<path fill-rule="evenodd" d="M1.5 1.5A.5.5 0 0 0 1 2v4.8a2.5 2.5 0 0 0 2.5 2.5h9.793l-3.347 3.346a.5.5 0 0 0 .708.708l4.2-4.2a.5.5 0 0 0 0-.708l-4-4a.5.5 0 0 0-.708.708L13.293 8.3H3.5A1.5 1.5 0 0 1 2 6.8V2a.5.5 0 0 0-.5-.5z"/>
	               		</svg>
	   				<%} %>
	   					<dl>
	   						<dt>
	   							<%if(tmp.getProfile() == null){ %>
		                     	<svg class="profile-image" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
		                          	<path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
		                          	<path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"/>
		                     	</svg>
		                  		<%}else{ %>
		                     		<img class="profile-image" src="${pageContext.request.contextPath}<%=tmp.getProfile()%>"/>
		                  		<%} %>
		                     	<span><%=tmp.getNick() %></span>
		                    	<%if(tmp.getNum() != tmp.getComment_group()){ %>
	                     			@<i><%=tmp.getTarget_nick() %></i>
	                  			<%} %>
	                  		</dt>
		   					<dd>
	   							<pre id="pre<%=tmp.getNum()%>"><%=tmp.getContent() %></pre>
	   							<span><%=tmp.getRegdate() %></span>
	   							<a data-num="<%=tmp.getNum() %>" href="javascript:" class="reply-link">답글</a>
		                    	<%if(id!=null && tmp.getWriter().equals(id)) {%>
		                    	<a data-num="<%=tmp.getNum() %>" href="javascript:" class="update-link">수정</a>
		                    	<a data-num="<%=tmp.getNum() %>" href="javascript:" class="delete-link">삭제</a>
		                    	<%} %>
	   						</dd>
	   					</dl>
	   					<form id="reForm<%=tmp.getNum() %>" class="animate__animated comment-form re-insert-form" action="comment_insert.jsp" method="post">
	   						<input type="hidden" name="ref_group" value="<%=dto.getNum()%>"/>
	   						<input type="hidden" name="target_nick" value="<%=tmp.getNick()%>"/>
	   						<input type="hidden" name="comment_group" value="<%=tmp.getComment_group()%>"/>
	   						<textarea name="content"></textarea>
	   						<button type="submit">등록</button>
	   					</form>
	   					<%if(tmp.getWriter().equals(id)) {%>
	   						<form id="updateForm<%=tmp.getNum() %>" class="comment-form update-form" action="comment_update.jsp" method="post">
			                  <input type="hidden" name="num" value="<%=tmp.getNum() %>" />
			                  <textarea class="form-control" name="content"><%=tmp.getContent() %></textarea>
			                  <button type="submit">수정</button>
			               </form>
	   					<%} %>
	   				</li>
	   			<%} %>	
	   		</ul>
	   </div>
	   	
   </div>
   <div class="loader">
	   	<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" fill="currentColor" class="bi bi-arrow-clockwise" viewBox="0 0 16 16">
		  <path fill-rule="evenodd" d="M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2v1z"/>
		  <path d="M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 0 1 8 4.466z"/>
		</svg>
   </div>

</div>
<script src="${pageContext.request.contextPath}/js/gura_util.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@9"></script>
<script>
	addReplyListener(".reply-link");
	addUpdateListener(".update-link");
	addUpdateFormListener(".update-form");
	addDeleteListener(".delete-link");
	
	
	
	let currentPage=1;
	let lastPage=<%=totalPageCount%>;
	let isLoading=false;
	
	window.addEventListener("scroll",function(){
		const isBottom=window.innerHeight + window.scrollY  >= document.body.offsetHeight;
		let isLast=currentPage==lastPage;
		if(isBottom&&!isLoading&&!isLast){
			document.querySelector(".loader").style.display="block";
			isLoading=true;
			currentPage++;
			
			ajaxPromise("ajax_comment_list.jsp","get","pageNum="+currentPage+"&num=<%=num%>")
			.then(function(response){
				return response.text();
			})
			.then(function(data){
	            document.querySelector(".comments ul").insertAdjacentHTML("beforeend", data);
	            
	            isLoading=false;
	            
	            addUpdateListener(".page-"+currentPage+" .update-link");
	            addDeleteListener(".page-"+currentPage+" .delete-link");
	            addReplyListener(".page-"+currentPage+" .reply-link");
	            addUpdateFormListener(".page-"+currentPage+" .update-form");
	       	
	            document.querySelector(".loader").style.display="none";
	         });
		}
		
	});
	
		
	function addReplyListener(sel){
		let replyLinks=document.querySelectorAll(sel);
		for(let i=0; i<replyLinks.length; i++){
			replyLinks[i].addEventListener("click",function(){
				const num=this.getAttribute("data-num");
				const form=document.querySelector("#reForm"+num);
				let current=this.innerText;
				if(current=="답글"){
					form.style.display="block";
					form.classList.add("animate__flash");
					this.innerText="취소";
					form.addEventListener("animationend",function(){
						form.classList.remove("animate__flash");
					},{once:true});
				}else if(current=="취소"){
					form.classList.add("animate__fadeOut");
		            this.innerText="답글";
					form.addEventListener("animationend", function(){
		                form.classList.remove("animate__fadeOut");
		                form.style.display="none";
		            },{once:true});
				}
			});
		}
		
	}
	
	function addUpdateListener(sel){
		let updateLinks=document.querySelectorAll(sel);
		for(let i=0; i<updateLinks.length; i++){
			updateLinks[i].addEventListener("click",function(){
				const num=this.getAttribute("data-num");
				const form=document.querySelector("#updateForm"+num);
				let current=this.innerText;
				if(current=="수정"){
					form.style.display="block";
					this.innerText="취소";
				}else if(current=="취소"){
		            this.innerText="수정";
		            form.style.display="none";
				}
			});
		}
	}
	
	function addUpdateFormListener(sel){
		let updateForms=document.querySelectorAll(sel);
		for(let i=0; i<updateForms.length; i++){
			updateForms[i].addEventListener("submit",function(e){
				const form=this;
				e.preventDefault();
				ajaxFormPromise(form)
				.then(function(response){
					return response.json();
				})
				.then(function(data){
					if(data.isSuccess){
						const num=form.querySelector("input[name=num]").value;
		                const content=form.querySelector("textarea[name=content]").value;
		                document.querySelector("#pre"+num).innerText=content;
		               	form.style.display="none";
					}
				});
			});
		}
	}
	
	   function addDeleteListener(sel){
		      let deleteLinks=document.querySelectorAll(sel);
		      for(let i=0; i<deleteLinks.length; i++){
		         deleteLinks[i].addEventListener("click", function(){
		               const num=this.getAttribute("data-num"); 
		               Swal.fire({
		        		   text: '댓글을 삭제하시겠습니까?',
		        		   icon: 'warning',
		        		   showDenyButton: true,
		        		   showCancelButton: true,
		        		   confirmButtonColor: '#000',
		        		   cancelButtonColor: '#f77028',
		        		   confirmButtonText: `Yes`,
		        		   denyButtonText: `Cancel`,
		        		 }).then((result) => {
		        		   if (result.isConfirmed) {
		        			   ajaxPromise("comment_delete.jsp", "post", "num="+num)
		 	                  .then(function(response){
		 	                     return response.json();
		 	                  })
		 	                  .then(function(data){
		 	                     if(data.isSuccess){
		 	                        document.querySelector("#reli"+num).innerText="삭제된 댓글입니다.";
		 	                     }
		 	                  });	        			 	        			   
		        		   } else if (result.isDenied) {
		        			   location.href="${pageContext.request.contextPath}/study/private/detail.jsp?num=<%=dto.getNum()%>";
		        		   }
		        		 })
		            });
		      }
		   }
	
	   document.querySelector("#postDelete").addEventListener("click", function(){
		   Swal.fire({
			   text: '작성하신 글을 삭제하시겠습니까?',
			   icon: 'warning',
			   showDenyButton: true,
			   showCancelButton: true,
			   confirmButtonColor: '#000',
			   cancelButtonColor: '#f77028',
			   confirmButtonText: `Yes`,
			   denyButtonText: `Cancel`,
			 }).then((result) => {
			   if (result.isConfirmed) {
				   location.href="${pageContext.request.contextPath}/study/private/delete.jsp?num=<%=dto.getNum()%>"
			   } else if (result.isDenied) {
				   location.href="${pageContext.request.contextPath}/study/private/detail.jsp?num=<%=dto.getNum()%>";
			   }
			 })
		   });
	
	
	
	let isLike=<%=isLike%>;
	let likeCount=<%=likeCount%>
	
	let likedSvg = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-heart-fill" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M8 1.314C12.438-3.248 23.534 4.735 8 15-7.534 4.736 3.562-3.248 8 1.314z"/></svg>';
	let likeSvg = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-heart" viewBox="0 0 16 16"><path d="m8 2.748-.717-.737C5.6.281 2.514.878 1.4 3.053c-.523 1.023-.641 2.5.314 4.385.92 1.815 2.834 3.989 6.286 6.357 3.452-2.368 5.365-4.542 6.286-6.357.955-1.886.838-3.362.314-4.385C13.486.878 10.4.28 8.717 2.01L8 2.748zM8 15C-7.333 4.868 3.279-3.04 7.824 1.143c.06.055.119.112.176.171a3.12 3.12 0 0 1 .176-.17C12.72-3.042 23.333 4.867 8 15z"/></svg>';
   
	let bookmarked = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-bookmark-check-fill" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M2 15.5V2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v13.5a.5.5 0 0 1-.74.439L8 13.069l-5.26 2.87A.5.5 0 0 1 2 15.5zm8.854-9.646a.5.5 0 0 0-.708-.708L7.5 7.793 6.354 6.646a.5.5 0 1 0-.708.708l1.5 1.5a.5.5 0 0 0 .708 0l3-3z"/></svg>';
	let bookmark = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-bookmark-check" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M10.854 5.146a.5.5 0 0 1 0 .708l-3 3a.5.5 0 0 1-.708 0l-1.5-1.5a.5.5 0 1 1 .708-.708L7.5 7.793l2.646-2.647a.5.5 0 0 1 .708 0z"/><path d="M2 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v13.5a.5.5 0 0 1-.777.416L8 13.101l-5.223 2.815A.5.5 0 0 1 2 15.5V2zm2-1a1 1 0 0 0-1 1v12.566l4.723-2.482a.5.5 0 0 1 .554 0L13 14.566V2a1 1 0 0 0-1-1H4z"/></svg>';
	
	document.querySelector(".like-link").addEventListener("click",function(){
		const num=this.getAttribute("data-num");
		if(isLike){
			ajaxPromise("study_unlike.jsp","post","num="+num)
			.then(function(response){
				return response.json();
			})
			.then(function(data){
				if(data.isSuccess){
					likeCount--; 
					document.querySelector(".like-link").innerHTML= likeSvg + "<span class='like-count'>" +likeCount + "</span>";
				}
			});
			isLike=false;
		}else{
			ajaxPromise("study_like.jsp","post","num="+num)
			.then(function(response){
				return response.json();
			})
			.then(function(data){
				if(data.isSuccess){
					likeCount++;
					document.querySelector(".like-link").innerHTML= likedSvg + "<span class='like-count'>" +likeCount + "</span>";
				}
			});
			isLike=true;
		}
	});
	
	   let isMark=<%=isMark%>;
	   let markCount=<%=markCount%>
	   
	   document.querySelector(".mark-link").addEventListener("click",function(){
	      const num=this.getAttribute("data-num");
	      if(isMark){
	         ajaxPromise("study_unmark.jsp","post","num="+num)
	         .then(function(response){
	            return response.json();
	         })
	         .then(function(data){
	            if(data.isSuccess){
	               markCount--; 
	               document.querySelector(".mark-link").innerHTML = bookmarked;
	            }
	         });
	         isMark=false;
	      }else{
	         ajaxPromise("study_mark.jsp","post","num="+num)
	         .then(function(response){
	            return response.json();
	         })
	         .then(function(data){
	            if(data.isSuccess){
	               markCount++;
	               document.querySelector(".mark-link").innerHTML = bookmark;
	            }
	         });
	         isMark=true;
	      }
	   });
	
</script>
</body>
</html>