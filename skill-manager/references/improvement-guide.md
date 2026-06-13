# Improvement Guide

How to improve a skill based on eval feedback and real-world usage.

## Core Principles

1. **Generalize from feedback**: Don't overfit to the specific test cases. Branch out and try different metaphors, different patterns of working.

2. **Keep the prompt lean**: Remove instructions that aren't pulling their weight. Read the transcripts — if the skill makes the model waste time on unproductive steps, remove those instructions.

3. **Explain the why**: Today's LLMs are smart. They have good theory of mind. Explain the reasoning behind instructions so the model understands why something is important. ALL CAPS and rigid MUSTs are yellow flags — reframe with reasoning.

4. **Look for repeated work across test cases**: If all test runs independently wrote the same helper script or took the same multi-step approach, bundle that script into the skill's `scripts/` directory.

## Improvement Plan Checklist

After reading feedback:
- [ ] Which test cases had specific complaints?
- [ ] Which test cases looked good (empty feedback)?
- [ ] Is there a common pattern across complaints (e.g., all format-related)?
- [ ] Can the fix be generalized, or is it test-case-specific?
- [ ] Would bundling a script eliminate repeated work?
- [ ] Is the issue in the instructions, the description, or the resources?

## Iteration Loop

1. Apply improvements to the skill
2. Rerun all test cases into a new `iteration-<N+1>/` directory
3. Launch the reviewer with `--previous-workspace` pointing at the previous iteration
4. Wait for user review
5. Read feedback, improve again
6. Stop when: user is happy, feedback is all empty, or not making meaningful progress

## Blind Comparison (Advanced)

For rigorous A/B testing, see `agents/comparator.md`. Give outputs to an independent agent without telling it which is which. Most users don't need this — the human review loop is usually sufficient.
