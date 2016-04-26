Getting started with Apache Tomcat 8.0.x in IntelliJ Ultimate Edition 2016.1
============================================================================

This guide provides a step-by-step introduction for how to set-up your
own local instance of a Tomcat server using IntelliJ Ultimate Edition
2016.1 as your IDE.

At the end of this document you will be able to receive query
parameters through the URL address bar (in other words an `HTTP GET`
request) in your browser, i.e.  given the URL

```
http://localhost:8080/?answer=42
```

you will be able to retrieve the `answer` parameter and its
value. Lastly we will accept user-input through standard HTML input
fields which is sent to us through the `HTTP POST` request method
and echo it back to the end-user.

**Note:** This guide makes heavy use of images, and you may have a
different theme set for your IntelliJ installation. If you like this
color scheme it is called Dracula and is available by default.

**Note:** In production you should sanitize HTML and user-input using
a third-party library such as the
[OWASP Java HTML sanitizer](https://www.owasp.org/index.php/OWASP_Java_HTML_Sanitizer_Project).
We will skip this pre-requisite and roll our own sanitizer in this guide
to save you the up-front time investment.

# Prerequisites

## IntelliJ 2016.1 Ultimate Edition

Acquiring the IDE is outside the scope of this tutorial, note that you
will **require** the Ultimate Edition to use Tomcat as the Community
Edition does not have support for
JavaEE. [Ultimate Edition is _free_ for students](https://www.jetbrains.com/shop/eform/students/). You
can use your University Email Address to apply for free
[Jetbrains products](https://www.jetbrains.com/) (IntelliJ is a
Jetbrains product) or with an ISIC/ITIC membership

## Java 8 JDK

You will require the Java 8 JDK, this guide has only been tested on
two Linux distributions, specifically Debian and Ubuntu. Installation
instructions for the Java 8 JDK is omitted here.

## Apache Tomcat

You will require
[Apache Tomcat 8.0.x](https://tomcat.apache.org/tomcat-8.0-doc/index.html)
which is, at the time of writing (2016-04-25) the latest stable
version of Tomcat. It works with Java 7 SE and later versions of Java.

Installing Tomcat requires `sudo` privileges!

### Installation instructions

1. Install Java JDK 8.
2. Download [the Core Tomcat 8.0.33 `tar.gz` file](http://apache.mirrors.spacedump.net/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.tar.gz) and decompress it. ([pgp](https://www.apache.org/dist/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33-windows-x86.zip.asc), [md5](https://www.apache.org/dist/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.tar.gz.md5), [sha1](https://www.apache.org/dist/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33-windows-x86.zip.sha1)).
3. Create a new directory `/opt/tomcat`, this requires `sudo` privileges!
4. Move the files from step 2 to the directory `/opt/tomcat`. This operation also requires `sudo`.
5. In your shell perform the following commands: (ensure that `JAVA_HOME` is set properly first)
   ``` 
   export CATALINA_HOME=/opt/tomcat
   ```
6. Start Tomcat by inputting `/opt/tomcat/bin/startup.sh` in your terminal.
7. Use your web browser to check that Tomcat is running by visiting [localhost:8080](http://localhost:8080/).

Clean up by killing Tomcat,

```
ps xu | grep tomcat | grep -v grep | awk '{ print $2 }' | xargs kill -9 
```

# Creating the IntelliJ project

Start by creating a new project in IntelliJ,

[[img/0-create-a-new-project.png]]

When creating the project it is important to create a Spring Project
(we won't actually use any Spring features) that is a web application
using a custom application server.

[[img/1-spring-application-server.png]]

We click the "New..." button and then select the "Tomcat Server" option

[[img/2-select-application-server.png]]

If you've followed the instructions _as is_ up to this point you can
input the path shown in the following image, otherwise specify the
absolute path to your Tomcat Home directory.

[[img/3-selecting-the-tomcat-home.png]]

We proceed by choosing our Project name and location. You may choose
any setting here and whenever you see "TomcatExample" in the
subsequent steps simply change it to reflect your chosen project name.

[[img/4-project-name-and-destination.png]]

IntelliJ generates some project boiler plate. If you cannot see the project
browser immediately (i.e. the directory tree) simply click the TomcatExample
button which is far up to your left (look at the top of the below image)

[[img/5-project-boilerplate.png]]

You can now run your Tomcat application straight out of the box by
finding the "Run" menu at the top of your IntelliJ window or using the shortcut `Shift+F10`. Input
[http://localhost:8080/](http://localhost:8080/) in your web-browser
and you will be presented with an empty page and the word`$END$`.

## Updating your website live

For this step leave Tomcat _running_ in IntelliJ, do _not_ close the
process.

In your `index.jsp` file (available in the `web` directory`) and
replace `$END$` with 

```
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Tomcat-logo.svg/2000px-Tomcat-logo.svg.png">
```

to use Tomcat to present an image of a Tomcat (meta).

Now use the short-cut `Ctrl+F10` to open the Update dialogue. Select
the "Update resources" option and refresh your web-browser `localhost`
session.

# Creating your custom servlet

In this section we will create our own servlet to replace the default
servlet provided by Tomcat. Essentially this boils down to extending
the proper classes and configuring our web application through its
configuration files.

Start by creating a package in your `src` directory. This is
_required_ as servlets have to be kept in a named package for
deployment, instead of the default "no-name" package.

First we write a naive, inflexible and illegible servlet (we will
decouple the HTML from the servlet soon),

```java
package example;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class MyHttpServlet extends HttpServlet {
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws IOException, ServletException {
        // Set the response message's MIME type.
        response.setContentType("text/html;charset=UTF-8");

        // Write the response message, in an HTML document.
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");  // HTML 5
            out.println("<html><head>");
            out.println("<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>");
            out.println("<title>TomcatExample</title></head>");
            out.println("<body>");
            out.println("<h1 style="font-size: 4em;">Hello, World!</h1>");
            out.println("</body></html>");
        }
    }
}
```

To use our servlet we have to add a deployment descriptor to our `web.xml` file
which is inside the `web/WEB-INF/` folder,

```
web
|
+-- index.jsp
|
+-- WEB-INF
     |
     +-- web.xml
```

We insert the following inside the `<web-app>` scope,

```
<servlet>
    <servlet-name>TomcatHelloWorldExample</servlet-name>
    <servlet-class>mypkg.HelloWorldExample</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>TomcatHelloWorldExample</servlet-name>
    <url-pattern>/tomcat_example</url-pattern>
</servlet-mapping>
```

The important part is the `<servlet>` and `<servlet-mapping>`
elements. 

The element `<servlet>` connects a Java Servlet class
(`example.MyHttpServlet`) to the servlet named
`MyHttpServlet`. Then the element `<servlet-mapping>` maps the servlet
`MyHttpServlet` to the URL pattern `/tomcat_example`. 

Combined together, the two elements essentially say that requests to
this web application at the URL `/tomcat_example` should be handled by the class
`example.MyHttpServlet`. 

Now we re-run our application (close it and start it again, or `Ctrl+F5) and
navigate to
[http://localhost:8080/tomcat_example](http://localhost:8080/tomcat_example).

Notice the extension after the port specifier. It is the
same as the `url-pattern` we defined in the `servlet-mapping` closure,
hence we are sending a request to the web application which is then
handled by the `MyHttpServlet`.

## Decoupling HTML and Java

We want to separate the behaviour of our servlet, which should tend to
business logic, which in the context of this application means retrieving the
appropriate data in response to the user query from the end-user
presentation, i.e. we do not want to pester our source with a
`PrintWriter`.

Conceptually we want our website to be composed in two distinct layers
the "business logic layer" which is handled by our Java Servlets and a
"presentation" layer, which we will handle with JSP.

We do this by imbuing the `HttpServletRequest` object with relevant
data before deferring the request to a JSP page, which is essentially
a HTML document with template capabilities.

Begin by overriding the `doGet` method inside the `MyHttpServlet` class,

```
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("title", "TomcatExample");
        request.setAttribute("foo", "Sterm trepers!");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
}
```

We set two arbitrary attributes. The `foo` attribute is meant to
demonstrate that there is not a set of allowed attributes, you may
define these on your own. The first argument is the name of the
attribute, the key, and the second argument is its value.

We then forward the request through to the `index.jsp` file which
we have updated to contain:

```
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title><%= request.getAttribute("title") %></title>
  </head>
  <body>
  <h1 style="font-size: 4em;">Ermahgerd, <%= request.getAttribute("foo") %></h1>
  </body>
</html>
```

Re-run your Tomcat application (as we changed the servlet we cannot
simply update the resources live as we must update the classes as
well) and notice how the tab title in your browser is "TomcatExample"
and that the page renders "Ermahgerd, Sterm trepers!" above the
Tomcat image.

# Accepting query parameters in the web-browser address bar

We will now proceed to accept a query parameter in the URL address
bar, specifically `?bar=`. 

We then update our `index.jsp` by discarding the image (its just noise
at this point) and call the `getParameter` method on the `request`
object.

```
<%-- index.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title><%= request.getAttribute("title") %></title>
  </head>
  <body>
  <h1 style="font-size: 4em;">Ermahgerd, <%= request.getAttribute("foo") %></h1>
  <h1 style="font-size: 4em;"><%= request.getParameter("bar") %></h1>
  </body>
</html>
```

Re-run your Tomcat application and visit
[http://localhost:8080/tomcat_example/?bar=42](http://localhost:8080/tomcat_example/?bar=42)
and observe how your page renders "42".

If you instead visit
[http://localhost:8080/tomcat_example/](http://localhost:8080/tomcat_example/)
you get "null" as there is no value set for the parameter.

## Accepting additional URI information

In this next section we will update our application to accept
additional URI information. This is important when accessing specific
resources and it will also allow us to showcase how to import Java
methods into our JSP file.

In the `doGet` method of the servlet replace the call to the `forward` method with
the `include` method,

```
request.getRequestDispatcher("/index.jsp").include(request, response);
```

We then proceed by updating the `<url-pattern>` inside the `web.xml`
file to `<url-pattern>/tomcat_example/*</url-pattern>`. The `*` is a
wildcard character so we will accept any text after the
`/tomcat_example` servlet specifier.  That is, it matches all sub-paths
under `/tomcat_example`.

Notice that we did not have to do this to accept query parameters in
the earlier step
.
In this step we will want to sanitize the user-input. As stated
earlier you should use a third-party library for doing this but we
will hand-roll our own to be brief.

Create the following class (disregard the implementation is not
important):

```java
// You can create the class in any package.
// It does not have to be inside the same package
// as the servlet.
package example;

public class HtmlSanitizer {
    public static String sanitize(String unsafeString) {
        if (unsafeString == null) return null;
        int len = unsafeString.length();
        StringBuilder result = new StringBuilder(len + 20);
        char aChar;

        for (int i = 0; i < len; ++i) {
            aChar = unsafeString.charAt(i);
            switch (aChar) {
                case '<': result.append("&lt;"); break;
                case '>': result.append("&gt;"); break;
                case '&': result.append("&amp;"); break;
                case '"': result.append("&quot;"); break;
                default:  result.append(aChar);
            }
        }

        return (result.toString());
    }
}
```

To access the `sanitize` method inside our JSP document
we update `index.jsp` with an import statement,

```
<%@ page import="example.HtmlSanitizer" %>
```

and call the method on the relevant string

```
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
  </body>
</html>
```

and re-run your application, this time visit
[http://localhost:8080/tomcat_example/apa?bar=2](http://localhost:8080/tomcat_example/apa?bar=2)

Your page should now look like this:

[[img/6-rendered-page.png]]

# Accepting HTTP POST requests

We end this guide by accepting user input provided on the web-page.

We add an additional method in our servlet that does the exact same
thing as the `doPost` method.

```java
@Override
public void doPost(HttpServletRequest request, HttpServletResponse response)
                   throws IOException, ServletException {
    doGet(request, response);
}
```

And update your `index.jsp` to:

```
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
```

You can now visit [localhost:8080/](localhost:8080/) or
[localhost:8080/tomcat_example/apa/some-stuff?bar=other-stuff](localhost:8080/tomcat_example/some-stuff?bar=other-stuff)
and enter values into the form, post the data through the send button
and watch the page update.

The following two figures shows the page
[localhost:8080/tomcat_example/some-stuff?bar=other-stuff](localhost:8080/tomcat_example/some-stuff?bar=other-stuff)
[before](localhost:8080/tomcat_example/some-stuff?bar=other-stuff) )
and
[after](http://localhost:8080/tomcat_example/some-stuff?firstname=Monorail&lastname=Cat)
the form has been posted.

[[img/7-before-send.png]]

[[img/8-after-send.png]]

# Closing statements

This concludes the guide, remember that this is just to get you
started with Tomcat. Next on your agenda is using React.js+Ajax+JSON as
opposed to JSP files to serve dynamic content.
 
[[TomcatExample]]
