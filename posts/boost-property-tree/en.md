Title: How to use boost::property_tree to load and write JSON
Author: Jérémy Cochoy
Data: 2015/12/21

Boost's Property Tree
=====================

**Property Tree** is a sublibrary of boost that allow you handling _tree of property_. It can be used to represent XML, JSON, INI files, file paths, etc. In our case, we will be interested in loading and writing JSON, to prvide an interface with other applications.

Our example case will be the following json file :

```{.json}
{
    "height" : 320,
    "some" :
    {
        "complex" :
        {
            "path" : "hello"
        }
    },
    "animals" :
    {
        "rabbit" : "white",
        "dog" : "brown",
        "cat" : "grey"
    },
    "fruits" : ["apple", "raspberry", "orange"],
    "matrix" : [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
}
```

Reading data
============

Let's have a look at how we can load those data into our c++ application.

Setting up
----------

First, we need to include the libraries and load the file.

```{.cpp}
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

// Short alias for this namespace
namespace pt = boost::property_tree;

// Create a root
pt::ptree root;

// Load the json file in this ptree
pt::read_json("filename.json", root);
```

Now, we have a populated property tree thatis waiting from us to look at him. Notice that you can also read from a stream, for example `pt::read_json(std::cin, root)`{.cpp} is also allowed.

If your json file is illformed, you will be granted by a `pt::json_parser::json_parser_error`.

Loading some values
-------------------

We can access a value from the root by giving it's path to the `get` method.

```{.cpp}
// Read values
int height = root.get<int>("height", 0);
// You can also go through nested nodes
std::string msg = root.get<std::string>("some.complex.path");
```

If the field your are looking to doesn't exists, the `get()` method will throw a `pt::ptree_bad_path` exception, so that you can recorver from incomplete json files. Notice you can set a default value as second argument, or use `get_optional<T>()` wich return a `boost::optional<T>`.

Notice the getter doesn't care about the type of the input in the json file, but only rely on the ability to convert the string to the type you are asking.

Browsing lists
--------------

So now, we would like to read a list of objects (in our cases, a list of animals).

We can handle it with a simple for loop, using an iterator. In **c++11**, it become :

```{.cpp}
// A vector to allow storing our animals
std::vector< std::pair<std::string, std::string> > animals;

// Iterator over all animals
for (pt::ptree::value_type &animal : root.get_child("animals"))
{
    // Animal is a std::pair of a string and a child

    // Get the label of the node
    std::string name = animal.first;
    // Get the content of the node
    std::string color = animal.second.data();
    animals.push_back(std::make_pair(name, color));
}
```

Since `animal.second` is a `ptree`, we can also call call `get()` or `get_child()` in the case our node wasn't just a string.

A bit more complexe example is given by a list of values. Each element of the list is actualy a `std::pair("", value)` (where value is a `ptree`). It doesnt means that reading it is harder.

```{.cpp}
std::vector<std::string> fruits;
for (pt::ptree::value_type &fruit : root.get_child("fruits"))
{
    // fruit.first contain the string ""
    fruits.push_back(fruit.second.data());
}

```

In the case the values arent string, we can just call `fruit.second.get_value<T>()` in place of `fruit.second.data()`.

Deeper : matrices
-----------------

There is nothing now to enable reading of matrices, but it's a good way to check that you anderstood the reading of list. But enought talking, let's have a look at the code.

```{.cpp}
int matrix[3][3];
int x = 0;
for (pt::ptree::value_type &row : root.get_child("matrix"))
{
    int y = 0;
    for (pt::ptree::value_type &cell : row.second)
    {
        matrix[x][y] = cell.second.get_value<int>();
        y++;
    }
    x++;
}
```

You can now read any kind of JSON tree. The next step is being able to read them.

Writing JSON
============

Let's say that now, we wan't to produce this tree from our application's data. To do that, all we have to do is build a `ptree` containing our data.
