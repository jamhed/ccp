# External References and Sources (Jest)

This document contains all external web references used in the jest-tester skill documentation. References are organized by topic for easy lookup.

## Jest Framework

### Official Documentation
- [Jest Getting Started](https://jestjs.io/docs/getting-started)
- [Jest API Reference](https://jestjs.io/docs/api)
- [Jest Mock Functions](https://jestjs.io/docs/mock-functions)
- [Jest Configuration](https://jestjs.io/docs/configuration)
- [Jest CLI Options](https://jestjs.io/docs/cli)

### Jest with TypeScript
- [Jest TypeScript Setup](https://jestjs.io/docs/getting-started#using-typescript)
- [ts-jest Documentation](https://kulshekhar.github.io/ts-jest/)
- [@jest/globals Package](https://jestjs.io/docs/api#jestfn)

### Jest Features
- [Jest Snapshot Testing](https://jestjs.io/docs/snapshot-testing)
- [Jest Async Testing](https://jestjs.io/docs/asynchronous)
- [Jest Timer Mocks](https://jestjs.io/docs/timer-mocks)
- [Jest Manual Mocks](https://jestjs.io/docs/manual-mocks)
- [Jest ES Module Support](https://jestjs.io/docs/ecmascript-modules)

## TypeScript Testing

### TypeScript Configuration
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [TypeScript with Jest](https://www.typescriptlang.org/docs/handbook/working-with-testing-frameworks.html)

### Type-Safe Testing
- [ts-jest Type Checking](https://kulshekhar.github.io/ts-jest/docs/getting-started/options/isolatedModules)
- [Jest Type Definitions](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/jest)

## Testing Best Practices

### Jest Resources
- [Jest Best Practices](https://jestjs.io/docs/snapshot-testing#best-practices)
- [Common Jest Mistakes](https://kentcdodds.com/blog/common-testing-mistakes)
- [Jest vs Vitest Comparison](https://blog.logrocket.com/vitest-vs-jest/)

### Testing Patterns
- [Arrange-Act-Assert Pattern](https://automationpanda.com/2020/07/07/arrange-act-assert-a-pattern-for-writing-good-tests/)
- [Testing Library Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

## Test-Driven Development (TDD)

### TDD with TypeScript
- [TDD with TypeScript for Beginners](https://blog.amanpreet.dev/test-driven-development-with-typescript-for-beginners)
- [TDD with TypeScript | michaelawad.io](https://michaelawad.io/test-driven-development-with-typescript/)
- [TDD in TypeScript & Jest | CodeSignal](https://codesignal.com/learn/paths/test-driven-development-in-typescript-jest)

### TDD Resources
- [Khalil Stemmler TDD Articles](https://khalilstemmler.com/articles/tags/test-driven-development/)
- [AWS TDD Best Practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/best-practices-cdk-typescript-iac/development-best-practices.html)

## React Testing

### Testing Library
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Jest DOM Matchers](https://github.com/testing-library/jest-dom)
- [Testing Library Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

### Component Testing
- [Testing React Components with Jest](https://jestjs.io/docs/tutorial-react)
- [React Testing Recipes](https://reactjs.org/docs/testing-recipes.html)

## Mocking Libraries

### MSW (Mock Service Worker)
- [MSW Documentation](https://mswjs.io/)
- [MSW with Jest](https://mswjs.io/docs/integrations/node)

### nock (HTTP Mocking)
- [nock Documentation](https://github.com/nock/nock)

## Zod Validation Testing
- [Zod Documentation](https://zod.dev/)
- [Zod Schema Testing Patterns](https://zod.dev/?id=basic-usage)

## Testing Pyramid and Strategies

### Testing Pyramid
- [Software Testing Pyramid Guide](https://www.browserstack.com/guide/testing-pyramid-for-test-automation)
- [Martin Fowler - Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)
- [Testing Trophy vs Pyramid](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)

## Package Managers

### npm/yarn
- [npm Documentation](https://docs.npmjs.com/)
- [Yarn Documentation](https://yarnpkg.com/getting-started)

## CI/CD Integration

### GitHub Actions
- [GitHub Actions for Node.js](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-nodejs)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

### Code Coverage
- [Codecov Documentation](https://docs.codecov.com/)
- [Jest Coverage Configuration](https://jestjs.io/docs/configuration#collectcoveragefrom-array)

## Research and Statistics

### Jest Characteristics
- Mature, battle-tested framework with extensive documentation
- Large plugin ecosystem and community support
- First-class snapshot testing support
- All-in-one solution (assertions, mocking, coverage)
- 95% API compatibility with Vitest for migration

### When to Use Jest
- Existing Jest codebases
- Projects requiring specific Jest plugins
- Teams familiar with Jest
- Projects needing snapshot testing
- React projects (historically standard)

### TDD Effectiveness
- 40-90% reduction in pre-release defect density
- 15-30% increase in initial development time
- 40% decrease in defect rates for TDD-adopting organizations

### Testing Pyramid Distribution
- Traditional: 70% unit, 20% integration, 10% E2E
- Modern adjustments: 60% unit, 25% integration, 15% E2E (UI-heavy)

## Notes

All URLs and references were current as of 2025. For the most up-to-date information, consult the official documentation links directly.

### Key Considerations for Jest
- Jest remains a solid choice for existing projects
- ESM support requires experimental flags
- ts-jest or @swc/jest for TypeScript support
- Consider Vitest for new projects (faster, native ESM)
- Use @jest/globals for explicit imports (recommended)
- Snapshot testing is a Jest strength
