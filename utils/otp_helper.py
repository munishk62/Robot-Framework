import pyotp


def get_otp_to_login(secret_key, issuer):
    otp = pyotp.TOTP(
        s=secret_key, digits=6, interval=30, digest="SHA1", issuer=issuer
    ).now()
    return otp
