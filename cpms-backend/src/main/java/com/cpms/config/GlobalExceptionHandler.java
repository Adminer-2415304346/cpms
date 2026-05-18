package com.cpms.config;

import com.cpms.dto.ApiResult;
import com.cpms.exception.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    /** 参数校验失败 → 400 */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResult<Void> handleValidation(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .map(err -> err.getDefaultMessage())
                .findFirst().orElse("参数校验失败");
        return ApiResult.error(400, msg);
    }

    /** JSON 解析失败（含日期格式错误）→ 400 */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResult<Void> handleNotReadable(HttpMessageNotReadableException e) {
        String msg = e.getMessage();
        if (msg != null && msg.contains("LocalDate")) {
            msg = "日期格式错误，请使用 yyyy-MM-dd 格式";
        }
        return ApiResult.error(400, msg != null ? msg : "请求参数格式错误");
    }

    /** 资源不存在 → 404 */
    @ExceptionHandler(NotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ApiResult<Void> handleNotFound(NotFoundException e) {
        return ApiResult.error(404, e.getMessage());
    }

    /** 业务校验错误 → 400 */
    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResult<Void> handleIllegalArgument(IllegalArgumentException e) {
        return ApiResult.error(400, e.getMessage());
    }

    /** 其他未捕获异常 → 500 */
    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResult<Void> handleRuntime(RuntimeException e) {
        return ApiResult.error(500, e.getMessage());
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResult<Void> handleException(Exception e) {
        return ApiResult.error(500, e.getMessage());
    }
}
