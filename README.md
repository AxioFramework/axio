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
### Web Server Interface
Consider:

* [Ruby: Rack](http://rack.github.io/)
* [Python: WSGI](https://www.python.org/dev/peps/pep-3333/)
* others?

### Authentication
### Authorization
### Routing
Consider:

* [Ruby: Roda](http://roda.jeremyevans.net/why.html)

### Input Validation
### Session Handling
### View Templates
### Web Sockets
### Database
### Security

* Cross-site scripting
* SQL injection
* etc.

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