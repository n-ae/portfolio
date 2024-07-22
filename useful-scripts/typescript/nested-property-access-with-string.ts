// https://www.typescriptlang.org/play/?#code/PTAEBEFMDMEsDtKgIagC4E8AOS0Atk1QAnSLUgZ0njQtEQrUgBNRyB7HYtWSCgKEw5QAOT5NmABWKdI3DAB4AKgBpQAaVCQAHk3jM6Aa0gZ20UEoB8oALz9QDjVt3UDoRsQQBze44D8FgDa6gC6znpu7ABGAFaQAMZovo7+oAAGACQA3uoAvgB02WKMLOomFMrBIZa5ackpoABcGvXNiABucvz8IBAwCEioAK48ADawmOjYuOwkCUPEFLCdoxigXpBEDBKgxhgCQkjFEmX7ytY2oFn1waAIuyZmFiHNxyzSsvLKauqWANz8XKBPZPJQhAE9MAAMSG8ESsHY8HQs2oFAWg3caE88C8c3IfGotHo4hYbBkXB4fFAT1Qh34Oiw7G4oGgsPhiPWmzeUnJckwImQAFtIOcABQcCkYV4k5inCpWACUzQ83iu9VIaAWSIlfLWyDoKpxANy3V6MLhPA5aFmGyI+CQOvk9CFkHp2kZzNZFoRSNtH0lAuFYsdmGaIPMSiVmOxuOuKQ1WrJn0m+uj3mNgmmoAAotohVhRpAlFnLnHHMhmmWGqAopX6tWHPE2kNBVE5ACG6Bch3HN36sxlVj04CIfFEYxiSUecmpaIZXKFLn84XizgLqAAOTIfJRfLxDd-UC9ABqyHGzCAA
// Define a type that represents nested properties
type NestedProperty<T, K extends keyof T> =
    K extends string
    ? T[K] extends object
    ? `${K}.${NestedKeys<T[K]>}`
    : K
    : never

// Define a utility type to recursively get nested keys
type NestedKeys<T> = {
    [K in keyof T]: NestedProperty<T, K>;
}[keyof T];

// Function to ensure a string represents nested properties of a type
export function getNestedPropertyName<T>(property: NestedKeys<T>): string {
    return property as string;
}

type ExampleType = {
    a: {
        b: {
            c: number;
        };
    };
    d: string;
};

const nestedProperty: NestedKeys<ExampleType> = 'a.b.c'; // Valid
