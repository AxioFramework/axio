<!--
# The MIT License (MIT)
Copyright (c) 2016 Brian Adkins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-->
![](https://avatars1.githubusercontent.com/u/17581796?v=3&s=200)
# Axio Framework
My goal for the **Axio** Framework is to extend the same joy of coding, expressive power, elegance and efficiency to the *specific* area of web application development as is already provided by **Racket** more *generally*.

For the time being, this README will be a sketchpad of ideas that will eventually coalesce into Axio.
## Aspirations
* A **community** of leaders and contributors that is genuinely kind, thoughtful, patient and effective.
* A **codebase** that is correct, clear, concise, efficient and valuable.
* An **architecture** that is modular, flexible, adaptable and enduring.
* A **framework** that programmers enjoy creating and using.

## Initial Assumptions
Purely in the interest of time, the following are presently assumed:

* New releases may break things
* Operating systems: Mac **OSX** and **Linux**
* Database: **Postgres**
* Front end http server (for proxying, ssl, etc.): **Nginx**

## Architecture Ideas
### Bootstrapping
### Web Server

* [Puma](http://puma.io/)

### Web Server Interface
Allow for *plugging* functions into the request/response pipeline. One motivating personal example is a server-side fix for a syntax error in a request from an iPad client which would've taken too long to push through Apple approval. The solution was a simple function injected into Rack middleware.

[Mailing list discussion](https://groups.google.com/forum/?hl=en#!topic/racket-users/M4byu6k7iNc)

Consider:

* [Ruby: Rack](http://rack.github.io/)
* [Python: WSGI](https://www.python.org/dev/peps/pep-3333/)
* others?

### Authentication
* HTTP Basic
* HTTP Digest
* Form based

### Authorization
### Routing
Consider:

* Ruby: Roda
    *  [website](http://roda.jeremyevans.net/why.html)
    *  [github](https://github.com/jeremyevans/roda)

### Input Validation
* Some Rails validators
    * inclusion_of
    * numericality_of
    * presence_of
    * absence_of
    * format_of - regex matching
    * uniqueness_of (database interaction)

### Session Handling
### Flash
### Controller Filters
### View Templates
[web-server/templates](https://docs.racket-lang.org/web-server/templates.html   )
### Web Sockets
Consider:

* [Rails ActionCable](https://github.com/rails/rails/tree/master/actioncable)

### Database
Consider:

* [Ecto](https://github.com/elixir-lang/ecto)
* [Diesel](http://diesel.rs/)
* [Snooze](http://planet.racket-lang.org/package-source/untyped/snooze.plt/2/9/planet-docs/snooze/index.html)
* [Persistent](http://www.yesodweb.com/book/persistent)

### Security

* Cross-site scripting
* SQL injection
* etc.

### Code Reloading
The ability to simply refresh the browser after changing code and have the new file automatically loaded is extremely helpful.

### Logging
* Associate log records from the same request e.g. thread/process id

### Continuations
[According to Jay](https://groups.google.com/d/msg/racket-users/bTBj-RbMLDA/k80HNazuFAAJ), the web-server/servlet module uses continuations, but everything else in the web server does not.
### Other

* Background tasks
* Cookies
* Email
* File uploads
* JSON
* New project code generation
* Testing

## Links
* [The Racket Language](http://racket-lang.org/)
* [Issue Tracker](https://github.com/AxioWebFramework/axio/issues)

## Copyright and License
Copyright &copy; 2016 Brian Adkins  
Axio Framework source code is licensed under the [MIT License](https://github.com/AxioWebFramework/axio/blob/master/LICENSE.md)