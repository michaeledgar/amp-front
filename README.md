# Rules

We've learned a lot about software development. Time to get serious.

## Commits

* In the past our commits weren't really well-factored, or really had structure. This makes reading our history hard.
* Use hg collapse to collapse several small commits into one logical commit.
* Branch locally to work on separate features. 

To do that, clone a local repo to another local repo. Change the branch on that other local repo. Make your commits. Then, in that clone, collapse your commits into something logical. Then, merge your changes into the `default` branch. This will show up as a fast-forward commit. Finally, push those to your main checkout. 

* One commit, one feature. If your feature doesn't fit in one nicely-sized commit, then prefix your commit message with "PARTIAL:".
* Until we have our own server, we can't really have code reviews. Until then: every commit that goes through, respond to it with *any* questions you have about the code. If you see nothing wrong, respond "LGTM". That stands for "Looks good to me." Continue this conversation until the other person says "LGTM". Otherwise, consider that commit incomplete.

## Tests

* Nothing goes in without a test of some kind. If you need to submit code that is untested, include a justification in your commit.
* Tests are either small, medium, or large.
* * Small tests are unit tests. They may need mocks to avoid interaction with other modules.
* * Medium tests are integration tests. This is testing modules' interactions with each other.
* * Large tests are functional tests. They test the whole system at once.

## Design

* Don't use anonymous arrays/hashes. Use objects. We're in rubyland.
* Defining classes is cheap. In Java, it'll take you thirty lines of code to make a small struct-like object. In Ruby, it takes us 3 or 4. Go for it! It's better to model the data you're moving around using classes than stuffing it into arrays and whatnot.
* * Exception: Returning two values can be okay. Justify it and make it crystal clear in the docs.

## Documentation

* Use YARD.
* Don't worry too hard about 1-liners.
* Document why, not what. If

## Code Style

* Strive for 80 columns.
* Never more than 100 columns.
* Don't make between 80-100 a habit.
* Descriptive method names.
* Parentheses in method declarations unless there are no arguments.
* Spaces around operators.
* No mathematic operator overloading. `[]`, `[]=` are fair game though.

## License

MIT. See LICENSE. No GPL code is allowed in this codebase.

By contributing code to the Amp Project, you agree to license your work under the MIT license.