// =========================================================
// detail.js — 상품 상세 (예지)
// 1) 사진 갤러리: 작은 사진(대표·옆모습·위에서)을 누르면 큰 사진이 바뀜
//    큰 사진을 누르면 팝업으로 크게 보기 (좌우로 넘기기)
// 2) 고객 커스텀: 카드를 누르면 크게 보기 창이 열림
// =========================================================
(function () {
  // ---------- 1) 사진 갤러리 ----------
  const mainImg = document.getElementById('galleryMain');
  const mainLabel = document.getElementById('galleryLabel');

  const thumbs = Array.from(document.querySelectorAll('.gallery-thumb'));

  // 사진 목록: 작은 사진들이 있으면 그 순서대로, 없으면 대표 사진 1장
  const photoBox = document.getElementById('galleryPhoto');
  const photos = thumbs.length
    ? thumbs.map(function (t) { return { src: t.dataset.src, label: t.dataset.label }; })
    : [{ src: photoBox ? photoBox.dataset.src : '', label: photoBox ? photoBox.dataset.label : '' }];
  let current = 0;   // 지금 보고 있는 사진 번호

  // n번 사진을 큰 사진 자리에 보여주기
  function showPhoto(n) {
    current = (n + photos.length) % photos.length;
    thumbs.forEach(function (t, i) { t.classList.toggle('active', i === current); });
    if (mainImg) {
      mainImg.style.visibility = 'visible';   // 이전 사진이 없어서 숨겨졌던 경우 다시 보이게
      mainImg.src = photos[current].src;
      mainImg.alt = photos[current].label;
    }
    if (mainLabel) mainLabel.textContent = photos[current].label;
  }

  thumbs.forEach(function (thumb, i) {
    thumb.addEventListener('click', function () { showPhoto(i); });
  });

  // ---------- 1-2) 사진 크게 보기 팝업 ----------
  const lightbox = document.getElementById('lightbox');
  const zoomBtn = document.getElementById('photoZoomBtn');
  if (lightbox && zoomBtn) {
    const lbImg = document.getElementById('lightboxImg');
    const lbCaption = document.getElementById('lightboxCaption');
    const lbCount = document.getElementById('lightboxCount');
    const prevBtn = document.getElementById('lightboxPrev');
    const nextBtn = document.getElementById('lightboxNext');

    // 사진이 1장뿐이면 좌우 버튼 숨기기
    prevBtn.hidden = nextBtn.hidden = photos.length < 2;

    function renderLightbox() {
      lbImg.style.visibility = 'visible';
      lbImg.src = photos[current].src;
      lbImg.alt = photos[current].label;
      lbImg.onerror = function () { lbImg.style.visibility = 'hidden'; };
      lbCaption.textContent = photos[current].label;
      lbCount.textContent = photos.length > 1 ? (current + 1) + ' / ' + photos.length : '';
    }
    function move(step) {
      showPhoto(current + step);   // 팝업에서 넘기면 뒤쪽 큰 사진·작은 사진도 같이 바뀜
      renderLightbox();
    }

    zoomBtn.addEventListener('click', function () {
      renderLightbox();
      lightbox.showModal();
    });
    prevBtn.addEventListener('click', function () { move(-1); });
    nextBtn.addEventListener('click', function () { move(1); });
    document.getElementById('lightboxClose').addEventListener('click', function () { lightbox.close(); });
    // 어두운 바깥 부분을 누르면 닫기
    lightbox.addEventListener('click', function (e) { if (e.target === lightbox) lightbox.close(); });
    // 키보드 ← → 로 넘기기 (Esc는 기본으로 닫힘)
    lightbox.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowLeft') move(-1);
      if (e.key === 'ArrowRight') move(1);
    });
  }

  // ---------- 2) 고객 커스텀 크게 보기 ----------
  const dialog = document.getElementById('showcaseDialog');
  if (!dialog) return;

  const img = document.getElementById('dialogImg');
  function setText(id, text) {
    const el = document.getElementById(id);
    el.textContent = text || '';
    el.hidden = !text;
  }

  document.querySelectorAll('.showcase-card').forEach(function (card) {
    card.addEventListener('click', function () {
      const d = card.dataset;
      img.style.visibility = 'visible';
      img.src = d.src;
      img.alt = d.writer + ' 님의 커스텀 케이크';
      img.onerror = function () { img.style.visibility = 'hidden'; };
      setText('dialogLettering', d.lettering ? '"' + d.lettering + '"' : '');
      setText('dialogOptions', d.options);
      setText('dialogContent', d.content);
      // 별점: 채운 별은 주황색(on), 나머지는 연한 색
      const stars = document.getElementById('dialogStars');
      stars.innerHTML = '';
      for (let s = 1; s <= 5; s++) {
        const star = document.createElement('span');
        star.textContent = '★';
        if (s <= Number(d.rating)) star.className = 'on';
        stars.appendChild(star);
      }
      stars.setAttribute('aria-label', '별점 ' + d.rating + '점');
      document.getElementById('dialogWriter').textContent = d.writer;
      dialog.showModal();
    });
  });

  document.getElementById('dialogClose').addEventListener('click', function () { dialog.close(); });
  // 창 바깥(어두운 부분)을 눌러도 닫히게
  dialog.addEventListener('click', function (e) { if (e.target === dialog) dialog.close(); });
})();
