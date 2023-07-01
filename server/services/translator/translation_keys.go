package translator

const KeysTest = "test"

// General Errors

const KeysNotEnoughPermissions = "generalErrors.notEnoughPermissions"
const KeysInternalError = "generalErrors.internalError"
const KeysInvalidOrExpiredTokenError = "generalErrors.invalidOrExpiredToken"

// Validation Errors

const KeysValidationRequiredError = "generalErrors.validation.fieldRequired"
const KeysValidationIncorrectEmailError = "generalErrors.validation.incorrectEmail"
const KeysValidationUnknownError = "generalErrors.validation.unknownValidationError"
const KeysInvalidFileFormat = "generalErrors.validation.invalidFileFormat"
const KeysCorruptedFile = "generalErrors.validation.corruptedFile"

// User Service

const KeysUserServiceErrorsNotFound = "userService.errors.notFound"
const KeysUserServiceErrorsAlreadyRegistered = "userService.errors.alreadyRegistered"
const KeysUserServiceErrorsChangeOwnStatus = "userService.errors.changeOwnStatus"
const KeysUserServiceSuccessfulLogin = "userService.successfulLogin"
const KeysUserServiceSuccessfulRegistration = "userService.successfulRegistration"
const KeysUserServiceStatusChanged = "userService.statusChanged"

// Shelter Service

const KeysShelterServiceShelterAlreadyExists = "shelterService.errors.alreadyExists"
const KeysShelterServiceShelterRemoved = "shelterService.shelterRemoved"
const KeysShelterServiceShelterAnimalRemoved = "shelterService.shelterAnimalRemoved"
