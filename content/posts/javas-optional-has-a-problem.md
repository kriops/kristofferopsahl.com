---
title: "Java's Optional has a Problem"
date: 2025-03-25T13:17:55.000Z
draft: false
tags: ["Java"]
math: true
showToc: true
cover:
  image: "/images/placeholders/java.svg"
  alt: "Java's Optional has a Problem"
---

Java's Optional is over a decade old, and has been subject to intense debate since long before its release. With this in mind, I will argue a particular aspect of its design was a rather unfortunate mistake, and show how it can lead to bugs. I will moreover discuss potential mitigations, and what a better design could have looked like.

While tangentially related, this post is not about Optional not being a monad. For more on that, I refer you to this somewhat famous [comment on the OpenJDK mailing list](https://mail.openjdk.org/pipermail/lambda-dev/2012-October/006365.html). Key excerpt: "(...) but the goal [with Optional] is NOT to create an option monad or solve the problems that the option monad is intended to solve."

## Background

This section introduces the key concepts in this post. If you are already familiar with mathematical functions and `Optional::map`, you may skip to the next section.

> 💡 For only code, and no mathematical notation – skip two sections ahead to the one named "Demo".

### Functions

A function is a mapping between two sets. A mapping between two sets can be informally defined as assigning every element in one set to exactly one element in another, e.g. $f: \mathbb{R} \mapsto \mathbb{R}$ defined by $f(x)=x^2$ maps from the set $\mathbb{R}$ of real numbers to itself.

Almost anything can be an element in a set, and a function does not have to be representable by an algebraic expression to be valid. For example: $f: \{\text{apple}, \pi\} \mapsto \{\text{red, green, blue}\}$ defined by $f(\text{apple})=\text{green}, f(\pi)=\text{red}$ is a valid function.

Combining functions by successive application is called function composition. Given two functions $f: A \mapsto B$ and $g: B \mapsto C$, one can define a third function in terms of the first two: $h: A \mapsto C$ defined by $h(x)=g\circ f=g(f(x))$. Function composition is not commutative, i.e. $g\circ f \neq f\circ g$.

### The Optional Class in Java

In the [official Java Platform 8 documentation](https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html) (since updated, though not significantly), the Optional class is described as follows:

> A container object which may or may not contain a non-null value. If a value is present, `isPresent()` will return `true` and `get()` will return the value.

Moreover, `Optional::map` is described as follows:

> If a value is present, apply the provided mapping function to it, and if the result is non-null, return an `Optional` describing the result. Otherwise return an empty `Optional`.

### Interaction Design

In the excellent *The Design of Everyday Things*, Don Norman introduces the idea of affordances, among other concepts. Affordances are the space of possible actions some agent can perform with some object. For example, a doorknob affords turning. Affordances may or may not be perceivable by the agent, in which case signifiers, e.g. labels, can be used to signal the affordances.

## The Problem

To 'map' or a 'mapping' in the context of applying a function to a value is unequivocally mathematical nomenclature. It is thus reasonable to expect `Optional::map` to adhere closely to the mathematical definition its naming invokes. To that point, let

$$U = \{x \in \mathbb{R} \mid x \text{ representable as a Double in Java}\}$$

Then consider the functions $f: U \mapsto U$, $g: U \mapsto U$, and $h: U \mapsto U$ defined by $h=g\circ f$. We implement $h$ as follows, given existing implementations of $f$ and $g$:

```java
Function<Double, Double> h =
      (Double x) -> Optional.of(x)
        .map(Example::f)
        .map(Example::g)
        .get();
```

*Function composition is achieved by successively calling `Optional::map` on the respective implementations of $f$ and $g$. `Optional::get` (unsafely) unwraps the resulting value.*

So far, so good. In practice, however, one frequently encounters functions with $\text{null}$ in their domain, co-domain, or both. Let us recall that a function is a mapping between two sets, and that a set can exist of arbitrary elements. Consequently, provided a mapping exists between $\text{null}$ and another entity, $\text{null}$ is computationally speaking a value. Let

$$V = U \cup \{ \text{null} \}$$

I.e., the set of all values returnable by a Java method whose signature is Double, including $\text{null}$.

Moreover, let $F: U \mapsto V$, $G: V \mapsto U$, and $H: U \mapsto U$ defined by $H=G\circ F$. Note that while *null* exists in the co-domain of $F$ and in the domain of $G$, it is neither a member of the domain nor the co-domain of $H$. In other words, there exists no $x$ such that $H(x) = \text{null}$, making $H$ very similar to $h$.

Let's assume that `Optional::map` behaves according to the mathematical definition of 'map'. Then, consider an implementation of $H$ similar to that of $h$. Consider now some value $x_1 \in U$, such that $F(x_1) = \text{null}$. By definition, some value $y_1 \in U$ exists, such that $H(x_1) = y_1$. Given our assumption, the Java implementation of $H$ is expected to return $y_1$ when applied to $x_1$:

```java
Function<Double, Double> H =
      (Double x) -> Optional.of(x) // Optional[x1]
        .map(Example::F) // Optional.empty
        .map(Example::G) // Optional.empty
        .get(); // Exception
```

*$x_1$ is denoted by `x1`.*

Alas, the implementation above yields an exception. Let's walk through, step-by-step:

- If `Example::F` returns $\text{null}$ when applied by `Optional::map`, the return value of `Optional::map` will be the empty Optional.
- The succeeding call to `Example::G` never happens because calling `Optional::map` on the empty Optional always returns the empty Optional.
- No value exists to be retrieved by `Optional::get`.
- The program throws an exception.

Thus, `Optional::map` is not a mathematical map, despite relying on the mathematical nomenclature in terms of naming, documentation, and related concepts.

To arrive at this conclusion, it would have been sufficient to show that calls to `Optional::map` arbitrarily excludes $\text{null}$ from the co-domain of its supplied functions. In my experience, however, the slight complexity present in situations which warrants function composition is far more likely to produce bugs that make into production.

## Demo

Let's look at slightly more plausible Java code. The antipattern previously described forms the blueprint for what is, according to my own experiences, a prevalent class of bugs in 'production grade' code.

> 👨🏻‍💻 I made the example small and hopefully easy to follow, but those who prefer it can browse the code on [GitHub](https://github.com/kriops/HelloOptional).

I have contrived of a simple example: Imagine we have a class representing arbitrary regular polygons with $n$ sides, i.e. $n$ vertices, and edges of length $s$. Moreover, the class is sloppily extended to represent lines, due to some combination of urgent business requirements and technical debt. Lines lack several properties of regular polygons, but can still be defined in terms of vertex count and edge length. The result might look something like this:

```java
package com.kristofferopsahl;

public record RegularPolygon(Integer n, Double s) {
  Double getArea() {
    if (n > 2) {
      return (n * Math.pow(s, 2)) / (4 * Math.tan(Math.PI / n));
    } else {
      return null;
    }
  }
}
```

*For business reasons, we have decided that the area of a line is **undefined**, and to represent that fact by returning `null`.*

For whatever reason, let's also presume we sometimes need to convert the area of our shapes to some other unit:

```java
package com.kristofferopsahl;

import java.util.Objects;

public class Utils {
  static Double convertSquareCmToSquareMeter(Double cm) {
    if (Objects.isNull(cm)) {
      return null;
    } else {
      return cm / 10000.0;
    }
  }
}
```

*A straight-forward unit conversion; if the area is undefined in terms of square centimeters, then it is also undefined in terms of square meters.*

Finally, two tests that each attempt to calculate the area of a line and represent the result in text. The first test avoids the use of Optional, and so we can represent the composite function over its entire domain. The second test uses Optional, so values for which the intermediate result is $\text{null}$ cannot be mapped.

```java
package com.kristofferopsahl;

import static org.junit.jupiter.api.Assertions.*;

import java.util.Objects;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class RegularPolygonTest {
  static final Integer numSides = 2;
  static final Double sideLength = 2.0;

  @Test
  void imperativeDemo() {
    final RegularPolygon shape = new RegularPolygon(numSides, sideLength);
    final Double areaInCm = shape.getArea();
    final Double areaInM = Utils.convertSquareCmToSquareMeter(areaInCm);
    final String areainSquareMeterAsString =
        Objects.isNull(areaInM) ? "Undefined" : areaInM.toString();
    assertNull(areaInM);
    assertEquals("Undefined", areainSquareMeterAsString);
  }

  @Test
  void optionalDemo() {
    final var maybeAreainSquareMeterAsString =
        Optional.of(new RegularPolygon(numSides, sideLength))
            .map(RegularPolygon::getArea)
            .map(Utils::convertSquareCmToSquareMeter)
            .map(areaInM -> Objects.isNull(areaInM) ? "Undefined" : areaInM.toString());
    assertFalse(maybeAreainSquareMeterAsString.isPresent());
  }
}
```

By virtue of both tests passing, it is confirmed that:

- $\text{Null}$ indeed acts as a value when we successively apply the functions **without** using `Optional::map`.
- $\text{Null}$ does not act as a value when we successively apply the functions **with** `Optional::map`.

## Discussion

So far, it has been shown in various ways that `Optional::map` is not a correct implementation of mapping. So what?

First and foremost, it is simply incorrect. When you borrow a cohort of concepts from another domain, they should behave in a manner that is consistent with that domain. Needlessly deviating from the original concepts introduces arbitrary complexity, which hinders cross-domain integration of knowledge for no tangible benefit. Concepts in Java that are virtually soaked in mathematical nomenclature should thus be painstakingly consistent in their implementation with the related mathematical concepts.

Despite this, we know that Optional is 'not intended to' behave according to the nomenclature it invokes, e.g., *map, option, value, function*. Granted, there is a strong case this was the correct decision in the context of the larger Java ecosystem, but why then invoke the aforementioned language? Doing so signifies non-existent affordances, and worse, it signifies subtly different affordances. This can make developers highly confident in slightly incorrect mental models, which potentially causes unhandled edge-cases, i.e., bugs.

Insofar instances of Optional are 'everyday things', one should strive for consistency between affordances and signifiers to the end of setting correct expectations for developers. This means Optional's interface should name and document its features in a manner distinct from unrelated concepts.

Another issue is that the current implementation of Optional obfuscates intent regarding handling of $\text{null}$-values. Assuming `Optional[null]` was a valid return value from `Optional::map`, one could implement the *current* behavior as follows:

```java
import java.util.Optional;

class Example {
  public static void main(String[] args) {
    Optional.of(Math.PI)
        .map(Example::F) // Optional[null] and NOT Optional.empty
        .flatMap(Optional::ofNullable)
        .ifPresent(Example::sideEffect);
  }

  /// ...
}
```

*In an alternate reality, Alt-Java developers must explicitly collapse `Optional[null]` to `Optional.empty`. In our current reality, a good Java IDE will warn you that the call to `Optional::flatMap` is superfluous.*

$\text{Null}$ has a multitude of meanings across various contexts, e.g. *missing value, zero, undefined*. The developer in the example above was forced to explicitly and unambiguously declare their interpretation of a $\text{null}$-value because Alt-Java does not *assume* `Optional[null]` should always collapse to `Optional.empty`. In our current reality, however, Java's Optional makes handling of $\text{null}$-values *implicit*, which further makes it difficult to infer from code alone whether the default behavior has been actively considered.

### Improving the design

The existing design is well established at this point, and so identifying defensive patterns is more pragmatic than lamenting a decade's old decisions. Taking a principled look still, I believe there are two mutually exclusive avenues to improvements: Making it a monad, or modifying language.

If we reject the stated goals and intentions of introducing Optional to the Java language, we could simply allow `Optional[null]` and be done with it. This is equivalent to making Optional a monad, and would instantaneously solve all issues related to the behavior of `Optional::map`. Simultaneously, it would solve the previously discussed incongruence between affordances and signifiers because if Optional is a monad, then the current language is no longer inaccurate.

Taking the existing implementation for granted, however, one could rename parts of the interface. In particular, 'map' should be avoided, so I would propose the following set of changes:

- `Optional` to `Result`
- `Optional::map` to `Result::transform`
- `Optional::flatMap` to `Result::transformAndFlatten`

Changing the name of the class itself immediately creates some linguistic distance to the pre-existing 'Option'-concept, while arguably being a better signifier for its intended use. `Optional::flatMap` is not a flatMap for the same reason `Optional::map` is not a map, so this would need changing as well.

### Mitigation

There unfortunately exists no panacea to circumvent the problems with `Optional::map`. If $\text{null}$ neither is nor will be in the range of the mapping function, then a plain application is appropriate:

```java
Optional.of(someValue)
        .map(Example::F) // F known to never return null.
        .map(Example::G)
        .ifPresent(Example::sideEffect);
```

*Breaks if F returns $\text{null}$.*

If a composite function may occur intermittent $\text{null}$-values over which it is well-behaved, then explicitly nesting calls (or using `Function::andThen`) is appropriate.

```java
Optional.of(someValue)
        .map(x -> G(F(x)))
        .ifPresent(Example::sideEffect);
```

*Breaks if F returns $\text{null}$, and G does not accept $\text{null}$.*

And if intermittent null-values have some meaning that is not encoded in the subsequent mapping function, i.e., we would like to apply some intermittent mapping from $\text{null}$ to another value, nesting Optionals is appropriate:

```java
Optional.of(someValue)
        .map(x -> Optional.ofNullable(F(x)).getOrElse(otherValue))
        .map(Example::G)
        .ifPresent(Example::sideEffect);
```

*It can also be achieved by explicitly nesting the intermittent mapping function, but now our intention is more explicit.*

This is not an exhaustive list, but it serves to highlight the fact that the ideal pattern changes with the characteristics of functions involved. It might also be problematic if these or related solutions lead to high-complexity anonymous functions, which are often synonymous with technical debt.

Another option entirely is to completely avoid using Optional. It *is* an excellent tool for control flow, so in this case I would consider a replacement rather than abandonment, e.g., [vavr.io](https://vavr.io/). Vavr provides an Option monad which does not suffer from any of the issues highlighted so far. It also provides union types through its Either monad, and collection monads, e.g., List. Some drawbacks of this approach include introducing an additional dependency, and requiring buy-in from your team and organization.

## Conclusion

`Optional::map` is incorrect, and it's too late to do anything about it. However, it's still a great tool. Therefore, use Optional, but apply appropriate mitigations to ensure your intentions are unambiguously communicated. And consider trying third-party alternatives.
