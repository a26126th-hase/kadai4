#!/bin/bash
# test_gcd.sh - gcd.sh の自動テスト
#   gcd.sh にさまざまな入力を与え、想定どおりの挙動でなければ終了コード1で終了する。
#   （GitHub Actions が失敗を検知できるようにするため必須）

GCD="./gcd.sh"
pass=0
fail=0

# 正常系: 標準出力が期待値と一致するか
#   引数: 説明, 入力1, 入力2, 期待する出力
check_output() {
    local desc="$1" a="$2" b="$3" expected="$4"
    local actual
    actual=$("$GCD" "$a" "$b" 2>/dev/null)
    if [ "$actual" = "$expected" ]; then
        echo "  [PASS] $desc : gcd($a, $b) = $actual"
        pass=$((pass + 1))
    else
        echo "  [FAIL] $desc : gcd($a, $b) は $expected を期待したが '$actual' だった"
        fail=$((fail + 1))
    fi
}

# 異常系: 終了コードが非0(=エラー終了)であることを確認
#   引数: 説明, gcd.sh に渡す引数すべて
check_error() {
    local desc="$1"; shift
    "$GCD" "$@" >/dev/null 2>&1
    local code=$?
    if [ "$code" -ne 0 ]; then
        echo "  [PASS] $desc : 正しくエラー終了 (exit=$code)"
        pass=$((pass + 1))
    else
        echo "  [FAIL] $desc : エラー終了すべきだが正常終了した (exit=0)"
        fail=$((fail + 1))
    fi
}

echo "=== 機能テスト（正常系）==="
check_output "2と4 → 2(課題の例)"  2   4  2
check_output "互いに素"            12  35  1
check_output "公約数あり"          12  18  6
check_output "一方が他方の倍数"    24   8  8
check_output "大きな数"          1071 462 21
check_output "引数の順序対称性"   462 1071 21

echo "=== 境界値テスト ==="
check_output "等しい値"             6   6  6
check_output "片方が1"              1  99  1
check_output "両方が1(最小)"        1   1  1

echo "=== 異常系テスト ==="
check_error  "引数なし"
check_error  "引数1つ:3(課題の例)"  3
check_error  "引数3つ"             12 8 4
check_error  "文字を入力(課題の例)" abc 5
check_error  "両方とも文字"        x y
check_error  "負の数"              -12 8
check_error  "小数"               12.5 8
check_error  "0は自然数でない"      0 5

echo ""
echo "=== 結果: PASS=$pass / FAIL=$fail ==="
if [ "$fail" -ne 0 ]; then
    echo "テスト失敗"
    exit 1
fi
echo "全テスト成功"
exit 0

