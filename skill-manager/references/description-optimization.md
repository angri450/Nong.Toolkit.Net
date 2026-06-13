# Description Optimization

Optimizing the frontmatter description for better triggering accuracy.

## How Triggering Works

Skills appear in Claude's `available_skills` list with name + description. Claude decides whether to consult a skill based on that description. Claude only consults skills for tasks it can't easily handle on its own — simple one-step queries may not trigger skills regardless of description quality.

## Eval Query Design

### Should-Trigger Queries (8-10)
Coverage across different phrasings — formal, casual, edge cases. Include cases where the user doesn't explicitly name the skill but clearly needs it.

### Should-Not-Trigger Queries (8-10)
Near-misses that share keywords with the skill but need something different. Adjacent domains, ambiguous phrasing. Don't make them obviously irrelevant.

### Query Quality
Good: "ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin as a percentage"

Bad: "Format this data", "Create a chart"

## Optimization Loop

```bash
dotnet run --project tools/SkillManager.Cli -- optimize-description .
```

The loop:
1. Splits eval set into 60% train / 40% held-out test
2. Evaluates current description (3 runs per query)
3. Calls Claude to propose improvements based on failures
4. Re-evaluates on both train and test
5. Iterates up to 5 times
6. Selects `best_description` by test score (not train) to avoid overfitting

## Review with User

Before running optimization, present eval queries to the user for review using the eval_review.html template in `assets/`. Bad eval queries lead to bad descriptions.

## Apply Result

Take `best_description` from JSON output and update SKILL.md frontmatter. Show before/after and report train/test scores.

## Honesty Boundary

See SKILL.md "Description Honesty Boundary" section. Optimization must not create descriptions that claim unsupported capabilities.
