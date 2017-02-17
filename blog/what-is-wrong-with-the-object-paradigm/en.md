---
title: Haskell - Lazy IO
author:
- Jérémy Cochoy
date: 2017/02/17
...

Object paradigm VS cathegoric paradigm : what is wrong with the object paradigm.
================================================================================


> The object paradigm is fondamentally wrong

If you are curious about programming languages and divers paradigms, you probablyu eard or read this sentence more than once.
THrough those lines, I'll try to draw a picture of the main reason that can lead to this conclusion.
What are the good side and wrong side of OOP, and how we can improve this paradigm by tuning it a little bit.
This nice "tunning" is actually already part of some languages, and i'll refer to it as the 'category paradigm'.

Where does the object paradigm comes from?
------------------------------------------

First, let's recall how, historically, we came to the object paradigm.
We are in the late 70s. The C language is now famous as it completely changed the way to write code compared to assembly, is human readable and have a monstruous expressivity in only few language words  and
he procedural paradigm[^procedural-paradigm] (the one you use while writting C) is well understood.
But, as applications grow and get an increassing size, developpers are facing an increassingly common problem : the code 's complexity is growing exponentially, and code gets harder and harder to write (it still sounds like a today's problem, right? :-) ).
The object paradigm was developped, expecting to solve the complexity curse. Here came OBJC and C++, both in 1983.

Saddly, we know today that OOP wasn't the Holly graal. But what did made peaples bealive that it would be, and why is OOP still used today?

The hopes of OOP
----------------

What came out from a lots of procedural developpement is that you often have types that describe some complexe structure (for example, lists in C are build of chained cells, each cell composed of a value and a link to the next cell) and functions operating on this type (using the same example, function for initialising empty list, destroying list, inserting into this list and removing value from it, etc.).
Once you have spoted this coding pattern, it sounds raisonable to formalise it so that you don't always have to rewrite it by hand, each time.
Indeed, this is the best way to involve : spot a pattern that peaple do mechanicaly, and automatise it. It worked for the automobile industry, and it palso did for computer developpement. Automatisation, from shell script... to new programming languages.

Genese of OOP
-------------

This was the genese of the object paradigm.
We call a such data type an object, add an
initialisation procedure always called at initialisation,
and an other one always called when the resource become unreachable.
Namely, OOP's constructor and destructors.
Because we always have a lot's of metode related to this object that
always need as argument this object,
we add them to the type definition and call them methods.

Here is an example of the C object pattern :
``` {.c}
struct object_type {
    int value1;
    int value2;
    char* ptr;
};

void initialize_object(struct object_type* obj) {
    obj->value1 = 7;
    obj->value2 = 3;
    obj->ptr = calloc(42, sizeof(char));
};

void release_object(struct object_type* obj) {
    free(obj->ptr);
}

int do_stuff(struct object_type* obj, int input) {
    obj->value1 += input;
    obj->value2 += 2;
    return obj->value1 + obj->value2;
};

//...
struct object_type obj;

{
    initialize_object(&obj);
    do_stuff(&obj, 5);
    release_object(&obj);
}

```

And the same thing now in C++:

``` {.cpp}
class Object {
public:
    Object();
    ~Object();
    int do_stuff(int input);
private:
    int value1;
    int value2;
    char* ptr;
};

Object::Object()
    :value1(7), value2(3) {
    ptr = calloc(42, sizeof(char));
};

Object::~Object() {
    free(obj->ptr);
}

int Object::do_stuff(int input) {
    value1 += input;
    value2 += 2;
    return value1 + value2;
};

//...
{
    Object obj;
    obj.do_stuff(5);
}
```

This example is quite simple, and show how object paradigm is applied both in C and C++ languages.
The second language is a lot more error-proof thanks to the support of the paradigm _in_ the language.

Now you might interupt me and argue 'object paradim isn't just about methods glued to a type'.
And you would be right. I swept under the rug _inheritence_.
This feature actually comes from an other spotted codding patters C developers was also doing quite frequently.
You reproduce the inheritence by agregating types, and using pointer arithmetic, as shown below.

``` {.c}
struct A {
    int u;
};

struct B {
    struct A parent;
    int v;
};

struct C {
    struct A parent;
    int w;
};

struct B obj_b;
struct C obj_c;
// Upcasting
struct A* p = (void*)&obj_b.parent;
struct A* q = (void*)&obj_c.parent;

```

The same code in C++ would be:

``` {.cpp}

// In C++, the struct keyword is like the class keyword,
// but all elements are by default public.

struct A {
    int u;
};

struct B : public A {
    int v;
};

struct C : public A {
    int w;
};

B obj_b;
C obj_c;
// Upcasting
A* p = &obj_b;
A* q = &obj_c;

```

[^procedural-paradigm]: Procedural paradigm means essentially that the language provide functions with side effects, and code is written linearly.
    You can see it like an enhencement of languages that only provide goto and jumps.
