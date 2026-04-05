---
aliases: ["/coding-agents-need-deterministic-feedback-a-case-for-phoenix/"]
title: "Coding Agents Need Deterministic Feedback: A Case for Phoenix"
date: 2025-12-07T22:44:43.000Z
draft: false
tags: ["AI", "Elixir"]
showToc: true
---

Let me preemptively acknowledge the fact that anyone who reads this probably has some level of LLM fatigue from social media. This article is about maximizing the potential benefit from LLM usage in the context of software engineering, which I (as one might infer from the title), in my humble opinion, have been fairly successful at. I will share the ideas with which I have found success, and I will leave the reader to determine their virtues and vices.

> 📄 This post is written with no LLM-assistance whatsoever. My blog is, and will forever be, completely comprised of my personal thoughts and ideas.

## Background
I normally do full-stack work with Java, Spring Boot, and something like React or Angular for the front-end. I tend to avoid ORMs and prefer writing SQL queries by hand. For event-driven features, my go-to tool is Apache Kafka, and I will typically use a rather diverse suite of other auxiliary tools depending on the project. 

I have felt for a while, however, that this little jungle of loosely connected tools has been a severely limiting factor in terms of working with coding agents such as Claude Code. They often struggle with the non-trivial complexities of leaky abstractions, poorly defined boundaries, and reliance on runtime side effects. For example, the prevalence of reflection in most JVM-based projects.

Therefore, when my latest client offered me complete freedom and autonomy with the express intent of maximally leveraging coding agents, I knew it was time to employ a technology I have been studying on the weekends for some time now: [Phoenix Framework](https://www.phoenixframework.org/) for [Elixir](https://elixir-lang.org/).

## Method
I have been interested in Phoenix for a while now, and the reasons are not fundamentally related to LLM usage. But it just so happens that the properties that make Phoenix great for developers in the first place also carry significant benefits when working with coding agents and LLMs. 

The core ideas and hypothesis behind why this is a great technology for coding agents are fairly simple:

- **Sufficient training data**: Elixir and Phoenix are not as popular as my regular weapons of choice, which are Java and Spring Boot. But they are popular enough that the LLMs have plenty of training data to draw on.
- **Vertical integration:** Elixir is a compiled language with dynamic but strong typing, and with [HTML + Embedded Elixir](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2) (HEEx), [Phoenix](https://www.phoenixframework.org/), [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html), and [Ecto](https://hexdocs.pm/ecto/Ecto.html), the compiler 'understands' the entire application from dynamic behavior in the front-end SPA to the structures, constraints, and relationships that are enforced by the database. 
- **Opinionated:** There is, for the most part, *one* idiomatic way of doing things in Phoenix. This *batteries-included* philosophy is something one might recognize from, e.g., [Django](https://www.djangoproject.com/), and significantly streamlines working with LLMs as there are fewer chances for a coding agent to lose track of, e.g., how the project approaches access control.
- **Terseness:** Phoenix is designed with terseness in mind, which is a major benefit to working with LLMs, where context management is key to obtaining high-quality output.
- **Elixir is designed for functional programming (FP):** Regardless of FP being at the center of [*bella sancta*](https://en.wikipedia.org/wiki/Religious_war) everywhere, I think it is entirely uncontroversial that immutability together with severe limitations of side effects is an obvious benefit when working with LLMs. This is because large spaces of possible errors are immediately eliminated for free, and because it further facilitates context management.

Simply summarized, we have a strong set of tools that facilitate a holistic approach for the coding agent while simultaneously allowing the agent to autonomously gather comprehensive, **deterministic feedback** to any set of proposed changes.

Moreover, the Elixir and Phoenix community and ecosystem, including the developers, seem keenly aware of the apparent synergies with coding agents: Fly.io (an excellent provider for cloud infrastructure for Elixir projects) launched a widely hyped product based on pre-configured cloud environments for LLM-based development with Phoenix, called [Phoenix.new](https://phoenix.new/), earlier this year. Furthermore, the AGENTS.md file used to define best practices for the coding agent in Phoenix.new is, as of [Phoenix 1.8.0](https://www.phoenixframework.org/blog/phoenix-1-8-released), included by default in all newly generated Phoenix projects.

All of this is to say that while Phoenix is already a highly attractive technology for LLM-driven development, they are also strategically embracing LLMs on a framework level to further nourish the existing synergies.

## Results
As of writing this, I have worked as a solo developer on the project for approximately two weeks. Here is a non-exhaustive list of what I have implemented in that time:

- A multi-tenant SaaS with full data isolation between tenants.
- An easy-to-understand, yet flexible, system for authentication and authorization. (This is a must when working with coding agents, as one can ill afford not to understand the security model.)
- A dynamic form builder.
- Anthropic integration for AI-assisted content generation.
- An asynchronous, event-driven system for batch processing of content.
- A dynamic, multi-dimensional taxonomy for application content. (Forming the basis for a soon-to-come RAG implementation to cover a core use case)
- Audit logging for admin actions.
- Tigris integration for file storage with authorized uploads and downloads.
- Redis integration for caching.
- Dashboards for all role types, relevant statistics, and the ability to manage important entities and relationships.
- Internationalization, including a full translation to Norwegian.
- Numerous LiveView GUIs to expose the implemented functionality to users.
- End-to-end integration tests for core workflows in the application.
- Static analysis (security, supply chain, code quality).
- Positive and negative unit tests for every single function call in the application. Since Elixir is a functional language, all of Phoenix is just a giant function call, which makes unit tests more powerful than what one might assume coming from Java.

I am intentionally being a bit vague because of secrecy requirements. But suffice to say we are well beyond the point of complexity where I have seen the utility of coding agents completely diminish in other projects, more often than not because of loosely coupled leaky abstractions. Moreover, I have already achieved a volume of functionality that would normally take a team of developers weeks, if not several months, of development.

In line with the original idea, I have tried to make as much of the codebase accessible to the Elixir compiler. The repository language distribution is as follows:

| Language | Percentage |
|----------|------------|
| Elixir | 93.7% |
| HTML | 5.8% |
| CSS | 0.2% |
| JavaScript | 0.2% |
| Dockerfile | 0.1% |
| Shell | 0.0% |

## Discussion
Working with coding agents does pose some unique challenges, and I am continuously developing an ever-increasingly sophisticated repertoire of techniques to manage them.

### Guard Rails
First and foremost, coding agents are nothing but LLMs in fancy wrapping paper, i.e., [stochastic parrots](https://en.wikipedia.org/wiki/Stochastic_parrot) that are prone to 'hallucinate.' It is important to defend against this [in depth](https://en.wikipedia.org/wiki/Defense_in_depth_(computing)):

#### Natural Language Instructions
Since I am using Claude Code, I can guide it by adding instructions to a special file named `CLAUDE.md` at the root of the repository (though there appears to be a slow convergence on using `AGENTS.md` for other agents). Moreover, there is a special syntax to refer to other files with further instructions from `CLAUDE.md`, so you can create separate files for instructions that are only relevant in some contexts. This reduces the risk of contradictions, implied or otherwise. 

Utilizing this feature, I have been able to preserve the original `AGENTS.md` that Phoenix generates with new projects, which prevents the description of best practices from morphing or diluting over time:

```markdown
@AGENTS.md

## Important Project-Specific Guidelines

### Do NOT Edit AGENTS.md

**NEVER modify the AGENTS.md file.** This file is generated by `phx.gen` and contains Phoenix best practices and framework-specific patterns. Editing it would override important conventions that ensure the project follows Elixir and Phoenix standards.

```

For now I have added further instructions to `CLAUDE.md` itself but I intend to follow the same pattern and split it into several files when the need arises. 

#### Automatic Testing and Static Analysis
I automatically invoke an extensive suite of unit tests, integration tests, and **deterministic tools for static analysis **on any set of proposed changes to the code base. There is nothing magic here: unit and integration tests are old (but gold) news and are immeasurably helpful in preventing LLM-induced regressions in the application. I ensure all [pure functions](https://en.wikipedia.org/wiki/Pure_function) have positive, negative, and edge cases covered by tests. And moreover, I ensure wide integration test coverage of core use cases in the application.

Additionally, I employ a linter, a security scanner, and a dependency scanner to help enforce idiomatic Elixir code and a strong security posture.

#### Agentic Code Review
With the dawn of coding agents, we have also gained the ability to use it for **stochastic code static analysis. **If you are unfamiliar, it works by having a code review agent (it's essentially a coding agent, but invoked in a specific context with a specific task) evaluate any set of proposed changes to the code base through natural language. This is great for several reasons, and I will highlight two in particular:

- Unless the proposed change is absolutely humongous, the code review agent will spend **significantly less of its context budget on the code base** compared to the actual coding agent. This means it is significantly more likely to catch violations of instructions in, e.g., `AGENTS.md`. 
- The code review agent produces a natural language report with detailed and concrete suggestions for improvement, meaning **it can be passed as-is back to the coding agent** with excellent results more often than not.

### Recursion Is King
If you haven't caught on by now, I am a massive proponent of functional programming. It should therefore come as no surprise that I rely heavily on what are essentially recursive instructions to the coding agent. It often goes something like this:

> Use extended thinking and planning mode to exhaustively address the issues raised in the latest PR comment. Repeat until no issues of medium importance or higher remain.The trick is that the 'latest PR comment' is an agentic code review that is automatically triggered upon submitting a change to the code base. This means that the agent will keep itself busy by iterating on the changes until the specialized critic is more or less happy. Thinking and planning mode is invoked to help the coding agent compartmentalize different points of feedback and address them one at a time.

After this process has concluded, I will, of course, perform a manual review as well. But I have found it highly effective, in combination with a well-developed `CLAUDE.md`, at eliminating trivial errors and having to tediously correct the same mistakes over and over.

### CLI Tooling Is Key
Simply put, if your agent can access server logs, GitHub issues, email conversations, and so on and so forth, it will be able to do more for you autonomously. That being said, [**DO NOT** give your coding agent the power to ruin your entire year](https://tech.yahoo.com/ai/articles/ai-vibe-coding-agent-deleted-211500354.html?guccounter=1&guce_referrer=aHR0cHM6Ly9rYWdpLmNvbS8&guce_referrer_sig=AQAAAC3M0a_ZR6COvuJ25P6XMO0LplGFOYR865N--benZDImA2gNTQknP696oCuZBQHeeYa2LR8vs7mW6pDy1cBiyCGdaleOrVV1DG0dK-IQ7NGQfEQDFK2QxOx_fev4HI05QPT2nEk-hndrGwVhA3qcyJHN_remnTsxYGEXnY5N7UHS). Use scoped API keys, virtualized environments, natural language instructions, backups, and other prophylactic measures to manage agentic risk. 

## Conclusion
Coding agents are an absolutely insane superpower if you are mindful of the associated risks and if you can be successful at context management. LLM-friendly technologies are of significant help to that end. While the project is still young, it is well past the point where I would normally expect to see a breakdown in LLM utility, and so I am highly optimistic about its future.
