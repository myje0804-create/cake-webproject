package com.minecake.controller.admin;

import com.minecake.dao.ProductDAO;
import com.minecake.dto.Product;
import com.minecake.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.nio.file.Files;
import java.nio.file.Path;
/**
 * AdminProductServlet — 역할 C
 * 할 일: 상품 등록·수정·삭제, Best 지정
 * 주소 예시: /admin/product?action=list
 */
@WebServlet("/admin/product")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 15     // 15MB
)

public class AdminProductServlet extends HttpServlet {
    // ★ 추가: 빈 값("" 또는 공백만 있는 값)이면 null로 바꿔 주는 함수
    private String emptyToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }
    private static final String PROJECT_ROOT = "";

            private Path getSourceImagePath(String folder, String savedFileName) {
            return Paths.get(PROJECT_ROOT, "src", "main", "webapp", "images", folder, savedFileName);
    }
    private void deleteImageFiles(String imageUrl) {
    System.out.println("[삭제 시도] imageUrl = " + imageUrl);
    if (imageUrl == null || imageUrl.isBlank() || "null".equals(imageUrl)) {
        System.out.println("[삭제 중단] imageUrl이 비어 있음");
        return;
    }

    String normalized = imageUrl.replace("\\", "/");
    if (normalized.startsWith("/webapp/")) {
        normalized = normalized.substring("/webapp/".length());
    } else if (normalized.startsWith("/")) {
        normalized = normalized.substring(1);
    }

    // 1) 프로젝트 소스 폴더: <PROJECT_ROOT>/src/main/webapp/<normalized>
    Path sourceFile = Paths.get(PROJECT_ROOT, "src", "main", "webapp").resolve(normalized);
    try {
        boolean deletedSrc = Files.deleteIfExists(sourceFile);
        System.out.println("[소스 삭제] path = " + sourceFile.toAbsolutePath() + ", deleted = " + deletedSrc);
    } catch (IOException e) {
        System.out.println("[소스 삭제 오류] " + sourceFile.toAbsolutePath());
        e.printStackTrace();
    }

    // 2) 웹루트 폴더: <webroot>/<normalized>
    String webrootBase = getServletContext().getRealPath("/");
    if (webrootBase != null) {
        Path webrootFile = Paths.get(webrootBase).resolve(normalized);
        try {
            boolean deletedWeb = Files.deleteIfExists(webrootFile);
            System.out.println("[웹루트 삭제] path = " + webrootFile.toAbsolutePath() + ", deleted = " + deletedWeb);
        } catch (IOException e) {
            System.out.println("[웹루트 삭제 오류] " + webrootFile.toAbsolutePath());
            e.printStackTrace();
        }
    }
}
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
    if (action == null || action.isBlank()) {
        action = "list";
    }

    if ("form".equals(action)) {
        // 상품 등록 폼으로 이동
        req.getRequestDispatcher("/admin/productForm.jsp").forward(req, resp);
        return;
    }

    if ("updateForm".equals(action)) {
        // 상품 수정 폼으로 이동 (기존 데이터 조회)
        String idParam = req.getParameter("productId");
        Product product = null;
        if (idParam != null && !idParam.trim().isEmpty()) {
            int productId = Integer.parseInt(idParam.trim());
            Connection conn = null;
            try {
                conn = DBUtil.getConnection();
                product = new ProductDAO().selectById(conn, productId);
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (conn != null) {
                    try { conn.close(); } catch (SQLException ignored) {}
                }
            }
        }
        req.setAttribute("product", product);
        req.getRequestDispatcher("/admin/productUpdateForm.jsp").forward(req, resp);
        return;
    }

    // 기본값("list"): 상품 목록 조회 후 이동
    List<Product> list = null;
    Connection conn = null;
    try {
        conn = DBUtil.getConnection();
        list = new ProductDAO().selectList(conn);
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignored) {}
        }
    }
    req.setAttribute("list", list);
    req.getRequestDispatcher("/admin/productList.jsp").forward(req, resp);

        // TODO: action 값에 따라 DAO 호출 → req.setAttribute(...) → JSP로 forward
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

    // 1. 삭제 처리 (fetch POST 요청 대응)
    if ("delete".equals(action)) {
        boolean ok = false;
        Connection delConn = null;
        String oldImageUrl = null;
        try {
            int delId = Integer.parseInt(req.getParameter("productId"));
            delConn = DBUtil.getConnection();
            Product target = new ProductDAO().selectById(delConn, delId);
             if (target != null) {
            oldImageUrl = target.getImageUrl();
        }
            new ProductDAO().deleteById(delConn, delId);
            ok = true;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (delConn != null) {
                try { delConn.close(); } catch (SQLException ignored) {}
            }
        }
        if (ok) {
        deleteImageFiles(oldImageUrl);
    }
        resp.setContentType("text/plain; charset=UTF-8");
        resp.getWriter().print(ok ? "ok" : "fail");
        return;
    }

    // 2. 등록(insert) 또는 수정(update) 처리
    String idStr = req.getParameter("productId");
    boolean isUpdate = (idStr != null && !idStr.trim().isEmpty());
    int productId = isUpdate ? Integer.parseInt(idStr.trim()) : 0;

    String type = req.getParameter("type");
    String category = emptyToNull(req.getParameter("category"));
    String name = req.getParameter("name");

    String priceStr = req.getParameter("price");
    int price = (priceStr != null && !priceStr.trim().isEmpty())
            ? Integer.parseInt(priceStr.trim()) : 0;

    String description = emptyToNull(req.getParameter("description"));
    boolean best = Boolean.parseBoolean(req.getParameter("best"));
    String oldImageUrl = req.getParameter("oldImageUrl");

    String folder = req.getParameter("folder");
    if (!Arrays.asList("cakes", "addons").contains(folder)) {
        folder = "cakes";
    }

    String imageUrl = isUpdate ? oldImageUrl : null;
    boolean imageReplaced = false;
    Part part = req.getPart("imageFile");
    if (part != null && part.getSize() > 0) {
        String submitted = part.getSubmittedFileName();
        if (submitted != null && !submitted.isBlank()) {
            String cleanName = Paths.get(submitted).getFileName().toString()
                    .replaceAll("[^a-zA-Z0-9._-]", "_");
            String fileName = System.currentTimeMillis() + "_" + cleanName;

           File dir = new File("src/main/webapp/images/" + folder);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            File destFile = new File(dir, fileName);
            byte[] fileBytes;
try (InputStream in = part.getInputStream()) {
    fileBytes = in.readAllBytes();
}
            // 1. 실제 톰캣 웹루트(브라우저 표시용)에 저장
            String realDirPath = getServletContext().getRealPath("/images/" + folder);
if (realDirPath != null) {
    Path webrootTarget = Paths.get(realDirPath, fileName);
    Files.createDirectories(webrootTarget.getParent());
    Files.write(webrootTarget, fileBytes);
    System.out.println("웹루트 저장 경로: " + webrootTarget.toAbsolutePath());
}

            // 2. 프로젝트 소스 폴더(src/main/webapp/images/...)에도 저장
           Path sourceTarget = getSourceImagePath(folder, fileName);
Files.createDirectories(sourceTarget.getParent());
Files.write(sourceTarget, fileBytes);
System.out.println("소스 저장 경로: " + sourceTarget.toAbsolutePath());

imageUrl = "/images/" + folder + "/" + fileName;
if (isUpdate) {
    imageReplaced = true;
}
        }
    }
    Product product = new Product();
    if (isUpdate) {
        product.setProductId(productId);
    }
    product.setType(type);
    product.setCategory(category);
    product.setName(name);
    product.setPrice(price);
    product.setDescription(description);
    product.setImageUrl(imageUrl);
    product.setBest(best);

    Connection conn = null;
    try {
        conn = DBUtil.getConnection();
        ProductDAO dao = new ProductDAO();
        if (isUpdate) {
            dao.update(conn, product);
            if (imageReplaced
                    && oldImageUrl != null && !oldImageUrl.isBlank() && !"null".equals(oldImageUrl)
                    && !oldImageUrl.equals(imageUrl)) {
                deleteImageFiles(oldImageUrl);
            }
        } else {
            dao.insert(conn, product);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    resp.sendRedirect(req.getContextPath() + "/admin/product");
        // TODO
    }
    }

    