<!--
# The MIT License (MIT)
Copyright (c) 2016-2019 Brian Adkins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-->
![](https://avatars1.githubusercontent.com/u/17581796?v=3&s=200)
# Axio Framework
My goal for the **Axio** Framework is to extend the same joy of coding, expressive power, elegance and efficiency to the *specific* area of web application development as is already provided by **Racket** more *generally*.

For the time being, this README will be a sketchpad of ideas that will eventually coalesce into Axio.

**Status update:** Although there has been little activity in this repository, I have been developing applications in Racket on a full time basis since November, 2018. After attending Racket Summer School in July, some of the macro-coding skills I'll need are coming along. I'm currently developing a significant web application in Racket for a startup, and I will be working on extracting the good parts into the Axio Framework over the next few months.
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

## Racket Web Links
* [Spin](https://github.com/dmac/spin)

## Documentation
Notes from a helpful IRC #racket conversation:

* Add a mydocs.scrbl file, using #lang scribble/manual
* To compile by hand:
`scribble --html --redirect-main http://docs.racket-lang.org/ +m myfile.scrbl`
* To have cross-references between your own files, you need this too:
`--info-out myfile.sxref ++info-in other1.sxref ++info-in other2.sxref ++info-in other3.sxref …`
* Make cross-references with `@section[#:tag "unique-name-across-all-files"]{My section}` and later (or in another file): `@secref{unique-name-across-all-files}` (hoping I didn't make any mistakes)
* if you're building a package, raco pkg install should build the docs too if you configured the package's info.rkt and other files properly.

Other info:

* [Scribble Docs](https://docs.racket-lang.org/scribble/index.html)
* Examples:
    * [Threading package](https://github.com/lexi-lambda/threading/blob/master/threading-doc/scribblings/threading.scrbl)
    * [String module](https://github.com/racket/racket/blob/master/pkgs/racket-doc/scribblings/reference/strings.scrbl)

## Architecture Ideas
### Bootstrapping
### Web Server
* Allow for graceful restarts e.g. the equivalent of kill -USR2 for Unicorn
* Consider technical implications of streaming

Consider:

* [Puma](http://puma.io/)

### Web Server Interface
Allow for *plugging* functions into the request/response pipeline. One motivating personal example is a server-side fix for a syntax error in a request from an iPad client which would've taken too long to push through Apple approval. The solution was a simple function injected into Rack middleware.

[Mailing list discussion](https://groups.google.com/forum/?hl=en#!topic/racket-users/M4byu6k7iNc)

Consider:

* [Elixir: Plug](https://github.com/elixir-lang/plug)
* [Ruby: Rack](http://rack.github.io/)
* [Python: WSGI](https://www.python.org/dev/peps/pep-3333/)
* [Scala: Finch](https://github.com/finagle/finch)
* others?

### Authentication
* HTTP Basic
* HTTP Digest
* Form based

### Authorization
### Routing
See [Routing.md](https://github.com/AxioWebFramework/axio/blob/master/Routing.md)

* URL currying? i.e. (curry my-helper-url a b) vs. (my-helper a b c) and produce a partial URL

Consider:

* Ruby: Roda
    *  [website](http://roda.jeremyevans.net/why.html)
    *  [github](https://github.com/jeremyevans/roda)
* [Scala: Finch](https://github.com/finagle/finch)

### Input Validation
* Some Rails validators
    * inclusion_of
    * numericality_of
    * presence_of
    * absence_of
    * format_of - regex matching
    * uniqueness_of (database interaction)
* Finch uses [functions](https://github.com/finagle/finch/blob/master/docs/endpoint.md#validation)

### Session Handling
### Flash
### Controller Filters
### View Templates
[web-server/templates](https://docs.racket-lang.org/web-server/templates.html   )
### Web Sockets
Consider:

* [Rails ActionCable](https://github.com/rails/rails/tree/master/actioncable)

### Database
* Migrations
* Functional query building
* Caching

Consider:

* [Ecto](https://github.com/elixir-lang/ecto)
* [Diesel](http://diesel.rs/)
* [Snooze](http://planet.racket-lang.org/package-source/untyped/snooze.plt/2/9/planet-docs/snooze/index.html)
* [Persistent](http://www.yesodweb.com/book/persistent)
* [JOOQ](http://www.jooq.org/)
* [Racquel](https://docs.racket-lang.org/racquel/index.html)

### Security

* Cross-site scripting
* Cross-site request forgery
* SQL injection
* String escaping
* etc.

### Code Reloading
The ability to simply refresh the browser after changing code and have the new file automatically loaded is extremely helpful.

### Asset Handling
* Minimize javascript/css
* Consolidate multiple javascript/css files
* Don't repeat the mistakes of the Rails *asset pipeline*

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
* Continuous Integration
* Continuous Deployment
* Open Source Reporting Services
  - Test Reporting
  - Code Coverage Reporting

## Links
* [The Racket Language](http://racket-lang.org/)
* [Issue Tracker](https://github.com/AxioWebFramework/axio/issues)

## Copyright and License
Copyright &copy; 2016-2019 Brian Adkins
Axio Framework source code is licensed under the [MIT License](https://github.com/AxioWebFramework/axio/blob/master/LICENSE.md)
