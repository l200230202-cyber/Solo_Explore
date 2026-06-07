<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Solo Explore</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #EFFFDB;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #275300 0%, #3B6D11 100%);
            padding: 40px 30px;
            text-align: center;
        }
        .header h1 {
            color: #ffffff;
            margin: 0;
            font-size: 28px;
            font-weight: 700;
        }
        .header p {
            color: #B2ED83;
            margin: 10px 0 0 0;
            font-size: 14px;
        }
        .content {
            padding: 40px 30px;
        }
        .content h2 {
            color: #275300;
            font-size: 22px;
            margin: 0 0 20px 0;
        }
        .content p {
            color: #42493B;
            font-size: 15px;
            line-height: 1.6;
            margin: 0 0 20px 0;
        }
        .button {
            display: inline-block;
            background: linear-gradient(135deg, #275300 0%, #3B6D11 100%);
            color: #ffffff !important;
            text-decoration: none;
            padding: 14px 32px;
            border-radius: 100px;
            font-weight: 700;
            font-size: 15px;
            margin: 20px 0;
            text-align: center;
        }
        .button:hover {
            background: linear-gradient(135deg, #3B6D11 0%, #275300 100%);
        }
        .token-box {
            background-color: #F5FAF0;
            border: 2px dashed #9DD770;
            border-radius: 12px;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
        }
        .token {
            font-size: 24px;
            font-weight: 700;
            color: #275300;
            letter-spacing: 2px;
            font-family: 'Courier New', monospace;
        }
        .footer {
            background-color: #F5FAF0;
            padding: 30px;
            text-align: center;
            border-top: 1px solid #D0EBB6;
        }
        .footer p {
            color: #727969;
            font-size: 13px;
            margin: 5px 0;
        }
        .warning {
            background-color: #FFF8EE;
            border-left: 4px solid #F59E0B;
            padding: 15px;
            margin: 20px 0;
            border-radius: 8px;
        }
        .warning p {
            color: #794E2E;
            font-size: 13px;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🗺️ Solo Explore</h1>
            <p>Jelajahi Keindahan Solo Raya</p>
        </div>
        
        <div class="content">
            <h2>Reset Password Anda</h2>
            
            <p>Halo,</p>
            
            <p>Kami menerima permintaan untuk mereset password akun Solo Explore Anda. Klik tombol di bawah ini untuk membuat password baru:</p>
            
            <div style="text-align: center;">
                <a href="{{ $url }}" class="button">Reset Password</a>
            </div>
            
            <p>Atau salin dan tempel link berikut ke browser Anda:</p>
            
            <div class="token-box">
                <p style="margin: 0; font-size: 12px; color: #727969;">Link Reset Password:</p>
                <p style="margin: 10px 0 0 0; word-break: break-all; font-size: 13px; color: #275300;">{{ $url }}</p>
            </div>
            
            <div class="warning">
                <p><strong>⚠️ Penting:</strong></p>
                <p>• Link ini hanya berlaku selama 60 menit</p>
                <p>• Jika Anda tidak meminta reset password, abaikan email ini</p>
                <p>• Jangan bagikan link ini kepada siapapun</p>
            </div>
            
            <p>Jika tombol di atas tidak berfungsi, salin dan tempel link di atas ke browser Anda.</p>
            
            <p>Terima kasih,<br><strong>Tim Solo Explore</strong></p>
        </div>
        
        <div class="footer">
            <p><strong>Solo Explore</strong></p>
            <p>Aplikasi Wisata Solo Raya</p>
            <p style="margin-top: 15px;">Email ini dikirim otomatis, mohon tidak membalas email ini.</p>
        </div>
    </div>
</body>
</html>
