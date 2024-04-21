#!/bin/bash
function git_sparse_clone() {
  branch=$1 repourl=$2 && shift 2
  TMPFILE=$(mktemp -d tmp.XXXX) || exit 1
  git clone -b $branch --depth=1 --filter=blob:none --sparse $repourl $TMPFILE
  cd $TMPFILE
  git sparse-checkout init --cone
  git sparse-checkout set $@
  mv -n $@ ../
  cd ..
  rm -rf $TMPFILE
}

function mvdir() {
  mv -n $(find $1/* -maxdepth 0 -type d) ./
  REPODIR=$(echo $1 | cut -d/ -f1)
  rm -rf $REPODIR
}

git clone --depth=1 https://github.com/ntlf9t/luci-app-easymesh
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns smartdns
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome
git clone https://github.com/tohojo/sqm-scripts.git package/sqm-scripts
git clone https://github.com/rufengsuixing/luci-app-usb3disable package/luci-app-usb3disable

git clone https://github.com/fullcone-nat-nftables/nft-fullcone
git clone https://github.com/chenmozhijin/turboacc

git_sparse_clone main https://github.com/kiddin9/openwrt-packages luci-app-oaf open-app-filter oaf 
git_sparse_clone main https://github.com/kiddin9/openwrt-packages luci-app-arpbind luci-app-vsftpd vsftpd-alt 
git_sparse_clone main https://github.com/kiddin9/openwrt-packages luci-app-vlmcsd vlmcsd

rm -rf ./*/.git* ./*/LICENSE
find ./*/ -type f -name '*.md' -print -exec rm -rf {} \;
find luci-theme-*/ -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

sed -i \
-e 's?\.\./\.\./\(lang\|devel\)?$(TOPDIR)/feeds/packages/\1?' \
-e 's?\.\./\.\./luci.mk?$(TOPDIR)/feeds/luci/luci.mk?' \
-e 's?2. Clash For OpenWRT?3. Applications?' \
*/Makefile

bash $GITHUB_WORKSPACE/.github/diy/create_acl_for_luci.sh -a >/dev/null 2>&1
bash $GITHUB_WORKSPACE/.github/diy/convert_translation.sh -a >/dev/null 2>&1
rm -rf create_acl_for_luci.*

exit 0
