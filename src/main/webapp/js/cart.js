// =========================================================
// cart.js — 장바구니 수량 − / + 버튼 (역할 B)
// 버튼을 누르면 숫자를 바꾸고 바로 서버에 저장(폼 전송)
// =========================================================
(function () {
  document.querySelectorAll('.qty-form').forEach(function (form) {
    const input = form.querySelector('.qty-input');

    form.querySelectorAll('.qty-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        const next = Number(input.value) + Number(btn.dataset.step);
        if (next < 1 || next > 10) return;   // 1~10개까지만
        input.value = next;
        form.submit();
      });
    });

    // 숫자를 직접 입력하고 칸을 벗어나면 저장
    input.addEventListener('change', function () {
      const n = Math.max(1, Math.min(10, Number(input.value) || 1));
      input.value = n;
      form.submit();
    });
  });
})();
