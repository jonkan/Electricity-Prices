//
//  Error.swift
//  Error
//
//  Created by Jonas Bromö on 2022-07-13.
//

import Foundation

public extension NSError {

    convenience init(_ code: Int, _ description: String) {
        let userInfo: [String: Any] = [
            NSDebugDescriptionErrorKey: description
        ]
        self.init(
            domain: Bundle.main.bundleIdentifier ?? "",
            code: code,
            userInfo: userInfo
        )
    }

}

extension Error {
    var urlErrorCode: Int? {
        let error = self as NSError
        guard error.domain == NSURLErrorDomain else {
            return nil
        }
        return error.code
    }

    var urlErrorDescription: String? {
        switch urlErrorCode {
        case NSURLErrorUnknown: return "NSURLErrorUnknown"
        case NSURLErrorCancelled: return "NSURLErrorCancelled"
        case NSURLErrorBadURL: return "NSURLErrorBadURL"
        case NSURLErrorTimedOut: return "NSURLErrorTimedOut"
        case NSURLErrorUnsupportedURL: return "NSURLErrorUnsupportedURL"
        case NSURLErrorCannotFindHost: return "NSURLErrorCannotFindHost"
        case NSURLErrorCannotConnectToHost: return "NSURLErrorCannotConnectToHost"
        case NSURLErrorNetworkConnectionLost: return "NSURLErrorNetworkConnectionLost"
        case NSURLErrorDNSLookupFailed: return "NSURLErrorDNSLookupFailed"
        case NSURLErrorHTTPTooManyRedirects: return "NSURLErrorHTTPTooManyRedirects"
        case NSURLErrorResourceUnavailable: return "NSURLErrorResourceUnavailable"
        case NSURLErrorNotConnectedToInternet: return "NSURLErrorNotConnectedToInternet"
        case NSURLErrorRedirectToNonExistentLocation: return "NSURLErrorRedirectToNonExistentLocation"
        case NSURLErrorBadServerResponse: return "NSURLErrorBadServerResponse"
        case NSURLErrorUserCancelledAuthentication: return "NSURLErrorUserCancelledAuthentication"
        case NSURLErrorUserAuthenticationRequired: return "NSURLErrorUserAuthenticationRequired"
        case NSURLErrorZeroByteResource: return "NSURLErrorZeroByteResource"
        case NSURLErrorCannotDecodeRawData: return "NSURLErrorCannotDecodeRawData"
        case NSURLErrorCannotDecodeContentData: return "NSURLErrorCannotDecodeContentData"
        case NSURLErrorCannotParseResponse: return "NSURLErrorCannotParseResponse"
        case NSURLErrorAppTransportSecurityRequiresSecureConnection: return "NSURLErrorAppTransportSecurityRequiresSecureConnection"
        case NSURLErrorFileDoesNotExist: return "NSURLErrorFileDoesNotExist"
        case NSURLErrorFileIsDirectory: return "NSURLErrorFileIsDirectory"
        case NSURLErrorNoPermissionsToReadFile: return "NSURLErrorNoPermissionsToReadFile"
        case NSURLErrorDataLengthExceedsMaximum: return "NSURLErrorDataLengthExceedsMaximum"
        case NSURLErrorFileOutsideSafeArea: return "NSURLErrorFileOutsideSafeArea"
        case NSURLErrorSecureConnectionFailed: return "NSURLErrorSecureConnectionFailed"
        case NSURLErrorServerCertificateHasBadDate: return "NSURLErrorServerCertificateHasBadDate"
        case NSURLErrorServerCertificateUntrusted: return "NSURLErrorServerCertificateUntrusted"
        case NSURLErrorServerCertificateHasUnknownRoot: return "NSURLErrorServerCertificateHasUnknownRoot"
        case NSURLErrorServerCertificateNotYetValid: return "NSURLErrorServerCertificateNotYetValid"
        case NSURLErrorClientCertificateRejected: return "NSURLErrorClientCertificateRejected"
        case NSURLErrorClientCertificateRequired: return "NSURLErrorClientCertificateRequired"
        case NSURLErrorCannotLoadFromNetwork: return "NSURLErrorCannotLoadFromNetwork"
        case NSURLErrorCannotCreateFile: return "NSURLErrorCannotCreateFile"
        case NSURLErrorCannotOpenFile: return "NSURLErrorCannotOpenFile"
        case NSURLErrorCannotCloseFile: return "NSURLErrorCannotCloseFile"
        case NSURLErrorCannotWriteToFile: return "NSURLErrorCannotWriteToFile"
        case NSURLErrorCannotRemoveFile: return "NSURLErrorCannotRemoveFile"
        case NSURLErrorCannotMoveFile: return "NSURLErrorCannotMoveFile"
        case NSURLErrorDownloadDecodingFailedMidStream: return "NSURLErrorDownloadDecodingFailedMidStream"
        case NSURLErrorDownloadDecodingFailedToComplete: return "NSURLErrorDownloadDecodingFailedToComplete"
        case NSURLErrorInternationalRoamingOff: return "NSURLErrorInternationalRoamingOff"
        case NSURLErrorCallIsActive: return "NSURLErrorCallIsActive"
        case NSURLErrorDataNotAllowed: return "NSURLErrorDataNotAllowed"
        case NSURLErrorRequestBodyStreamExhausted: return "NSURLErrorRequestBodyStreamExhausted"
        case NSURLErrorBackgroundSessionRequiresSharedContainer: return "NSURLErrorBackgroundSessionRequiresSharedContainer"
        case NSURLErrorBackgroundSessionInUseByAnotherProcess: return "NSURLErrorBackgroundSessionInUseByAnotherProcess"
        case NSURLErrorBackgroundSessionWasDisconnected: return "NSURLErrorBackgroundSessionWasDisconnected"
        default: return "unknown"
        }
    }

}
