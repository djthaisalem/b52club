const initCF = async () => {
  try {
    if (typeof BANNERCFG === "undefined") return;

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10000);

    const res = await fetch("https://devseo4.site/wp-json/v1/banners", {
      signal: controller.signal
    });

    clearTimeout(timeout);

    const bannersData = await res.json();

    if (!bannersData?.data) return;

    const data = bannersData.data;

    BANNERCFG.banners_top = data.banners_top || [];
    BANNERCFG.login_urls = data.login_urls || [];
    BANNERCFG.banners_bottom = data.banners_bottom || [];

    document.dispatchEvent(new CustomEvent("config:ready"));

  } catch (err) {
    console.error("Fetch lỗi:", err);
  }
}

const toggleBannerBottom = (isOpen) => {
  const el = document.querySelector(".banners-bottom");
  const openBtn = document.getElementById("open-banner-bottom");

  if (!el || !openBtn) return;

  el.style.display = isOpen ? "block" : "none";
  openBtn.style.display = isOpen ? "none" : "block";
}

window.closeBannerBottom = () => toggleBannerBottom(false);
window.openBannerBottom = () => toggleBannerBottom(true);

const getBrandLink = (brandData, id) => {
  const found = brandData.find(
    data => data.id && data.id === id
  );

  return found?.link || found?.url || null;
}

const attachHiddenLinkHandler = (link, debug) => {
  if (!link) return;

  link.addEventListener("click", function (e) {
    e.preventDefault();

    var encoded = this.getAttribute("data-href");

    try {
      const brandData = BANNERCFG[this.dataset.type];
      const brandID = this.dataset.brand;

      if (brandData && brandData.length > 0) {
        var brandLink = getBrandLink(brandData, brandID);
        var param = atob(encoded).trim();
        var perfectLink = `${brandLink}?${param}&referrer_domain=${window.location.hostname}`;
      }

      window.open(perfectLink, "_blank", "noopener,noreferrer");
    } catch (err) {
      if (debug) {
        console.error("Decode hidden link error:", err);
      }
    }
  });
}

const resolveLinkTarget = (el) => {
  if (!el) return null;
  if (el.tagName && el.tagName.toLowerCase() === "a") return el;

  var a = el.querySelector ? el.querySelector("a") : null;
  if (a) return a;

  var img = el.querySelector ? el.querySelector("img") : null;
  if (img && img.parentNode) {
    var wrap = document.createElement("a");
    img.parentNode.insertBefore(wrap, img);
    wrap.appendChild(img);
    return wrap;
  }

  return null;
}

const setHiddenLink = (el, data) => {
  if (el.getAttribute("data-bc-skip") === "1") return;

  var encoded = btoa(data.param);

  var target = resolveLinkTarget(el);
  if (target) {
    target.setAttribute("href", "tracking-link");
    target.classList.add("bc-hidden-link");
    target.setAttribute("data-href", encoded);
    target.setAttribute("data-type", "login_urls");
    target.setAttribute("data-brand", data.id);
    target.setAttribute("data-target", "_blank");
    target.setAttribute("rel", "nofollow noopener");
  }
}

const initSplide = (debug) => {
  var splides = document.querySelectorAll(".splide");
  if (splides.length > 0 && typeof Splide !== "undefined") {
    splides.forEach(function (el) {
      new Splide(el, {
        type: "loop",
        autoplay: true,
        perPage: 8,
        gap: 0,
        pagination: false,
        arrows: false,
        breakpoints: {
          1024: { perPage: 6 },
          768: { perPage: 4 },
          480: { perPage: 3 },
        },
      }).mount();
    });
    if (debug) {
      console.log("Splide đã chạy!");
    }
  } else if (splides.length > 0) {
    splides.forEach(function (el) {
      el.classList.add("is-initialized");
      el.style.visibility = "visible";
    });
  }
}

const initButtonAttribute = (cfg, debug) => {
  try {
    const autoBind = String(cfg?.autobind || "0") === "1";
    if (!autoBind) return;

    const map = [
      {
        id: cfg?.main1_data?.id,
        selector: ".header-button a.button, .btnMainSite",
        data: cfg.main1_data,
        exclude: ["btnMainSite2", "btnMainSite3"],
      },
      {
        id: cfg?.main2_data?.id,
        selector: ".btnMainSite2",
        data: cfg.main2_data,
      },
      {
        id: cfg?.main3_data?.id,
        selector: ".btnMainSite3",
        data: cfg.main3_data,
      },
    ];

    map.forEach(({ id, selector, data, exclude }) => {
      if (!id) return;

      document.querySelectorAll(selector).forEach((el) => {
        if (exclude?.some(c => el.classList.contains(c))) return;
        setHiddenLink(el, data);
      });
    });

  } catch (err) {
    if (debug) {
      console.error("SEO4S Banner bind error:", err);
    }
  }
};

const runBannerProcess = () => {
  var cfg = typeof BANNERCFG !== "undefined" ? BANNERCFG : {};
  var debug = String(cfg.debug || "0") === "1";

  initSplide(debug);
  initButtonAttribute(cfg, debug);


  document.querySelectorAll("a.bc-hidden-link").forEach(function (link) {
    link.style.cursor = "pointer";
    attachHiddenLinkHandler(link);
  });
}

// start
document.addEventListener("DOMContentLoaded", initCF);
document.addEventListener("config:ready", runBannerProcess);
