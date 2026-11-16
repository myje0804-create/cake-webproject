// =========================================================
// banner.js — 메인 배너 슬라이드
// 좌우 버튼 / 아래 점 클릭 / 5초마다 자동 넘김
// =========================================================
(function () {
  const slides = document.querySelectorAll('#bannerTrack .banner-slide');
  const dots = document.querySelectorAll('#bannerDots button');
  const prevBtn = document.getElementById('bannerPrev');
  const nextBtn = document.getElementById('bannerNext');

  if (slides.length === 0) return;

  let current = 0;      // 지금 보이는 배너 번호
  let timer = null;     // 자동 넘김 타이머

  // n번 배너 보여주기
  function show(n) {
    // 마지막 다음은 처음으로, 처음 이전은 마지막으로
    current = (n + slides.length) % slides.length;

    slides.forEach((slide, i) => slide.classList.toggle('active', i === current));
    dots.forEach((dot, i) => dot.classList.toggle('active', i === current));
  }

  function startAuto() {
    stopAuto();
    timer = setInterval(() => show(current + 1), 5000);
  }
  function stopAuto() {
    if (timer) clearInterval(timer);
  }

  // 버튼을 누르면 이동하고, 자동 넘김 시간은 처음부터 다시 셈
  prevBtn.addEventListener('click', () => { show(current - 1); startAuto(); });
  nextBtn.addEventListener('click', () => { show(current + 1); startAuto(); });
  dots.forEach((dot, i) => dot.addEventListener('click', () => { show(i); startAuto(); }));

  // 마우스를 올려두면 멈춤
  const banner = document.querySelector('.banner');
  banner.addEventListener('mouseenter', stopAuto);
  banner.addEventListener('mouseleave', startAuto);

  // 움직임 줄이기 설정을 켠 사용자는 자동 넘김 안 함
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    startAuto();
  }
})();
