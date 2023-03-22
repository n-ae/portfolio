export const convertToTranslationWithParams = <T>(
    obj: T,
    translationKey: string,
    param: keyof T,
): any => {
    if (!obj) return;

    const value = obj[param];
    if (!value) return;

    return {
        code: translationKey,
        params: {
            [param]: value,
        },
    };
};
