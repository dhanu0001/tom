<%-- index.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="example.HtmlSanitizer" %>

<html>
  <head>
    <title><%= request.getAttribute("title") %></title>
  </head>
  <body>
  <h1 style="font-size: 4em;">Ermahgerd, <%= request.getAttribute("foo") %></h1>
  <h1 style="font-size: 4em;"><%= request.getParameter("bar") %></h1>

  <!-- The sanitize method is called on the line below -->
  <h1 style="font-size: 4em;"><%= HtmlSanitizer.sanitize(request.getRequestURI()) %></h1>

  <form method='get'>
    Firstname: <input type='text' name='firstname'><br />
    Lastname: <input type='text' name='lastname'><br />
  <input type='submit' value='SEND'>
  </form>

  <h1 style="font-size: 4em;">Firstname: <%= HtmlSanitizer.sanitize(request.getParameter("firstname")) %></h1>
  <h1 style="font-size: 4em;">Lastname: <%= HtmlSanitizer.sanitize(request.getParameter("lastname")) %></h1>

  </body>
</html>
