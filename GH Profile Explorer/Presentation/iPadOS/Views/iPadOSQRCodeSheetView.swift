#if os(iOS)
import SwiftUI

struct iPadOSQRCodeSheetView: View {
    private enum Constants {
        enum Layout {
            static let qrCodeSize: CGFloat = 200
            static let spacing: CGFloat = 20
        }
        
        enum Strings {
            static let scanQRTitle = "scan_qr_title".localized
            static let githubPrefix = "github.com/"
            static let closeButton = "close".localized
        }
        
        enum Images {
            static let qrCode = "qrcode"
        }
    }
    
    let user: UserUIModel
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Text(Constants.Strings.scanQRTitle)
                .font(.headline)
            
            Image(systemName: Constants.Images.qrCode)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.Layout.qrCodeSize, height: Constants.Layout.qrCodeSize)
            
            Text(Constants.Strings.githubPrefix + user.login)
                .font(.caption)
            
            Button(Constants.Strings.closeButton) {
                onClose()
            }
            .buttonStyle(.bordered)
            .padding(.top)
        }
        .padding()
    }
}

#Preview {
    iPadOSQRCodeSheetView(
        user: UserUIModel.mock(),
        onClose: {}
    )
}

#endif 