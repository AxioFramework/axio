# Routing
For each route, I'll need the following information:

* URL Pattern (required) e.g.
  "/"
  "/:org_shortname/product_image/:style/:filename"
  "/:org_shortname/products/(*id).json"

* Function to handle request (required)

* Accepted HTTP verbs (optional, defaults ot all)

* Name (optional) - used to do "reverse routing" i.e. produce a URL from parameters

* Contraints (optional) - further refine the pattern matching e.g. type/format of params

Here's an example from Rails:

```
Foo::Application.routes.draw do
  match "/:org_shortname/product_image/:style/:filename" => 'product_images#product_image',
    :as => :product_image, :via => :get, :constraints => { :filename => /.jpg$/ }

  # URL pattern: "/:org_shortname/product_image/:style/:filename"
  # Function: ProductImagesController.product_image
  # Name: :product_image
  # Verbs: GET
  # Contraints: filename param must end in .jpg

  match '/products/(*id).json'  => 'products#show', :via => :get

  # URL pattern: '/products/(*id).json'
  #    (*id) globs everything between /products/ and .json including / chars
  # Function: ProductsController.show
  # Verbs: GET
end
```

There are many other aspects (much of which is just syntax sugar) of routing in Rails that I'm ignoring initially.

I'm thinking of something like the following:

```
(routes
  ("/" home-page)
  ("/:org_shortname/product_image/:style/:filename" product-image #:verbs (get)
   #:name prod-image #:when (regexp-match #rx".jpg$" filename))
  ("/products/(*id).json" product-show #:verbs (get)))
```

The first two arguments (url-pattern function) are required, so they're positional. The optional arguments are specified with keywords.

Instead of:  #:verbs (get)    would it be better to have  #:verbs get  and dynamically check for an atom vs. list ?

Consider *not* allowing intra-node params. For example, *disallow* "/foo/bar-:id" Instead this could be handled with "/foo/:id" *plus* a constraint that the id is of the form `/bar-(\d+)/`

My initial goal is just for the "base" syntax. Sugar can be added later for some cases.

[Racket mailing list thread](https://groups.google.com/forum/?hl=en#!topic/racket-users/wZ07AM8SBuw)
