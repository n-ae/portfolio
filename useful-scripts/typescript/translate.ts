import { formatNumber } from './number';

export const formatNumberWithTranslation = (number: number, globalEntityId: string): string => {
    const thousandsSeparator = translateWithFallback(`thousands_separator.${globalEntityId}`);
    const decimalSeparator = translateWithFallback(`decimal_separator.${globalEntityId}`);
    return formatNumber(number, thousandsSeparator, decimalSeparator);
};

// export const tWithFallback = (key: string, globalEntityId: string): string => {
//     const subEntityTranslationKey = `${key}.${globalEntityId}`;
//     const subEntityTranslation = t(subEntityTranslationKey);
//     if (subEntityTranslation !== subEntityTranslationKey) return subEntityTranslation;

//     console.log(`No translation found for:\n${subEntityTranslationKey}\nFalling back to:\n${key}`);

//     return t(key);
// }

export const getFallbackKey = (key: string, fallbackCount: number): string => {
    const translation = t(key);
    // can fallback and translation is failed
    if (fallbackCount > 0 && translation === key) {
        const translationKeyLogicalSeparator = '.';
        const lastIndex = key.lastIndexOf(translationKeyLogicalSeparator);
        // fallback was not possible
        if (lastIndex < 0) return translation;

        const fallenbackKey = key.slice(0, lastIndex);
        console.log(`No translation found for:\n${key}\nFalling back to:\n${fallenbackKey}`);

        return getFallbackKey(fallenbackKey, --fallbackCount);
    }

    return key;
};

export const translateWithFallback = (key: string, fallbackCount = 1): string => {
    const fallenbackKey = getFallbackKey(key, fallbackCount);
    return t(fallenbackKey);
};
