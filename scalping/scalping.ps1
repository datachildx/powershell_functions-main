function scalping_3080 {
    <#
    .Description
    Function to look for 3080 from best buy.
    To Do:
    No Notifcation is set.
    #>
    param(
        $cycle = 180
    )
    $stop = $true 
    while ($stop) {
        $nvidia3080 = (Invoke-WebRequest -Uri "https://www.bestbuy.com/site/nvidia-geforce-rtx-3080-10gb-gddr6x-pci-express-4-0-graphics-card-titanium-and-black/6429440.p?skuId=6429440" -Headers @{
            "method"="GET"
                "authority"="www.bestbuy.com"
                "scheme"="https"
                "path"="/site/nvidia-geforce-rtx-3080-10gb-gddr6x-pci-express-4-0-graphics-card-titanium-and-black/6429440.p?skuId=6429440"
                "cache-control"="max-age=0"
                "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not\`"A\\Brand`";v=`"99`""
                "sec-ch-ua-mobile"="?1"
                "dnt"="1"
                "upgrade-insecure-requests"="1"
                "user-agent"="Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Mobile Safari/537.36"
                "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
                "sec-fetch-site"="same-origin"
                "sec-fetch-mode"="navigate"
                "sec-fetch-user"="?1"
                "sec-fetch-dest"="document"
                "referer"="https://www.bestbuy.com/site/customer/lists/manage/saveditems"
                "accept-encoding"="gzip, deflate, br"
                "accept-language"="en-US,en;q=0.9"
                "cookie"="UID=7d4e1dd6-8bd5-4e7a-80f6-5dabb9f281fe; pst2=187|N; oid=1849122241; vt=67299256-83e1-11eb-b7c7-06bf21f39007; CTT=ee86adbfb16ce4a65237d6f31c48a091; optimizelyEndUserId=oeu1615628969867r0.6320492253722221; s_ecid=MCMID%7C22915097749882965310719551298928580209; bm_sz=6F48ED504886012A31451451E7ED15CB~YAAQFu9jaAD0Gxp4AQAAjm3YLwv+QyrXvWc7Q92aKfnEagGykwYQ9UseIVuHikRY7nMtqyt/BHQBl5i1/G08N4cxMUITbPw7s/g8aIEXSH70RBmB4YrppV1+YrMf7wHz/nKkkKHe7q25ct/e4ospPHpp0kOiB9pYcW2150VnS9vl+4M1DlLawqT4d6yhqrETybnmVWpmUob3KrmTIAgSPEJPiIfLXDAdDHDMtcxDDaxC831qe7/gXFYXrBXHQCaBsIeng9O7HLemNgfDw3/M2a4DOp1HcT39UqVEBeA=; campaign=198_Hatch_0; aam_uuid=16526823486034678890062714155498291027; 52245=; _cs_c=1; _gcl_au=1.1.127855961.1615710425; CRTOABE=1; analyticsStoreId=187; locDestZip=94102; locStoreId=187; partner=198%26Hatch%262021-03-14+02%3a37%3a00.000; campaign_date=1615711027587; ui=1615711202869; G_ENABLED_IDPS=google; DYN_USER_CONFIRM=4cd27067904ca57b1d12bbdd856f17b9; DYN_USER_ID=ATG49335322780; pt=3457541092; ut=02e86e50-84a1-11eb-afe0-02f2d23c63ff; at=eyJhY2Nlc3NUb2tlbiI6IllXTXRBX3pydm9TaEVldTlxUVo5LTdxUnd3ZjhHSW9YQ3FFMmlhWDR6Yk5qQ1ROdVBkZXVBQUFBQUFBQUFBQSIsInRpbWVUb0xpdmUiOjE4MDAsImlzc3VlZFRpbWVzdGFtcCI6MTYxNTcxMTI2NTY0NCwiYXNzZXJ0aW9uIjoidTpIU0V3Wmw0VlVybWlWeFo4RWw2THdzOVREVGp0UndaTmgxYWc5YnlCZl9VIiwicHJpbmNpcGFsIjoidTpIU0V3Wmw0VlVybWlWeFo4RWw2THdzOVREVGp0UndaTmgxYWc5YnlCZl9VIiwicHJpbmNpcGFsSWRlbnRpZmllciI6IjAyZTg2ZTUwLTg0YTEtMTFlYi1hZmUwLTAyZjJkMjNjNjNmZiIsImNvbnN1bWFibGUiOmZhbHNlLCJ2ZXJzaW9uIjoiMS4wIn0.DRKV_MCD2a-WDmgEAwDPJLzCkdySoDfcmGjOnbvd-xiaSfxXe1GxHS_poYuYqFjM7ZFm7HLB30MUyzLigWIavw; s_cc=true; s_vi=[CS]v1|3026EB349D74CACF-400018390DC83CFE[CE]; SID=82273504-7de1-4f48-8dc9-7dfd4c6daa46; rxVisitor=16157144105342BT4AIB6RK1H8RU7N3DLIJ5O1UJSR2U1; dtSa=-; COM_TEST_FIX=2021-03-14T09%3A33%3A30.758Z; c6db37d7c8add47f1af93cf219c2c682=c202fd70a7ae4b45a225542a28822f3a; basketTimestamp=1615714409452; _abck=25E67313EDD3C290D236775BAC0EE4F1~0~YAAQtTkZuMnlwBl4AQAA7FwVMAXLVlpQxqdZIXJAsTiYaU5BizpOIy4J2Dlm4hL+9DAtEeIO16Kfem8LDnEJtebtmmTmHL0WMyKZSNMQ3y0ekoaHCckAmF1JKHLfXbOYG9gzs1sSxYSaCQEyYu7Rdc25/mcsQUORpy0OPRsP4rtyhWQf1xxAcgdSkGlccd8phO8RmJXh1ICRcG0mA7xcgzIQi/1aAXDaILnd81+QFMyoASqprHLN2hFW2+YpGadDFXOnb53AhZxoXcVoaYiHvSYmZPR6b0ttL47ZqwLEdv7WuOFPJNFurdXR+g4YHBy4am65lfaFXSo/ZuijbA6Yfu5H51XFsQ2sslLLD8D4IB3fcCBrAedk2hK8+Oe5Ax8ltClntUseoaTBKE8I9FFlhCyR4xNC7ACv2xT8D9dUhzMrsGPGqxo5hma0qsj8c/7n~-1~||-1||~-1; AMCVS_F6301253512D2BDB0A490D45%40AdobeOrg=1; _cs_mk=0.05528208971758497_1615714414740; AMCV_F6301253512D2BDB0A490D45%40AdobeOrg=1585540135%7CMCMID%7C22915097749882965310719551298928580209%7CMCAID%7CNONE%7CMCOPTOUT-1615721614s%7CNONE%7CvVersion%7C4.4.0%7CMCAAMLH-1616319214%7C9%7CMCAAMB-1616319214%7Cj8Odv6LonN4r3an7LhD3WZrU1bUpAkFkkiY1ncBR96t2PTI%7CMCCIDH%7C1247087220; analyticsToken=02e86e50-84a1-11eb-afe0-02f2d23c63ff; dtCookie=v_4_srv_2_sn_78U47TRSOTBMU3HMRGG0O8TE1NH6JL3L_app-3Aea7c4b59f27d43eb_1_app-3A1b02c17e3de73d2a_1_ol_0_perc_100000_mul_1; rxvt=1615716714389|1615714410535; dtPC=2`$514912666_386h-vPHJEVIGPUHPKQFJMTKWKMQKARQFDHVLU-0e5; sc-location-v2=%7B%22meta%22%3A%7B%22CreatedAt%22%3A%222021-03-14T08%3A30%3A29.606Z%22%2C%22ModifiedAt%22%3A%222021-03-14T09%3A41%3A54.656Z%22%2C%22ExpiresAt%22%3A%222022-03-14T08%3A41%3A54.656Z%22%7D%2C%22value%22%3A%22%7B%5C%22physical%5C%22%3A%7B%5C%22zipCode%5C%22%3A%5C%2294102%5C%22%2C%5C%22source%5C%22%3A%5C%22A%5C%22%2C%5C%22captureTime%5C%22%3A%5C%222021-03-14T09%3A41%3A54.534Z%5C%22%7D%2C%5C%22destination%5C%22%3A%7B%5C%22zipCode%5C%22%3A%5C%2294102%5C%22%7D%2C%5C%22store%5C%22%3A%7B%5C%22storeId%5C%22%3A187%2C%5C%22zipCode%5C%22%3A%5C%2294103%5C%22%2C%5C%22storeHydratedCaptureTime%5C%22%3A%5C%222021-03-14T09%3A41%3A54.655Z%5C%22%7D%7D%22%7D; dtLatC=1; c2=Computers%20%26%20Tablets%3A%20Computer%20Cards%20%26%20Components%3A%20GPUs%20%2F%20Video%20Graphics%20Cards%3A%20pdp; _cs_id=1e4491cb-540a-a3d7-b5bd-4dcc053f491a.1615710424.2.1615714917.1615714415.1614089558.1649874424793.Lax.0; _cs_s=4.1; s_sq=%5B%5BB%5D%5D; bby_prc_lb=p-prc-w; bby_rdp=l"
            })

        if ($nvidia3080.Content -match '<strong>Sold Out</strong>') {
            write-host -NoNewline "scalping_3080 ##" -ForegroundColor DarkBlue
            write-host "out of stock"
        } else {
            $stop = $false
            write-host -NoNewline "scalping_3080 ##" -ForegroundColor DarkBlue
            write-host "omg IN STOCK CHECK"
            Send-MailMessage
        }
        Start-Sleep $cycle
    }
}