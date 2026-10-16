package com.fusion.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 项目的启动类
 *
 * 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章
 * 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章
 * 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章
 *
 */
@SuppressWarnings("SpringComponentScan") // 忽略 IDEA 无法识别 ${fusion.info.base-package}
@SpringBootApplication(scanBasePackages = {"${fusion.info.base-package}.server", "${fusion.info.base-package}.module"})
public class FusionServerApplication {

    public static void main(String[] args) {
        // 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章
        // 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章
        // 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章

        SpringApplication.run(FusionServerApplication.class, args);
//        new SpringApplicationBuilder(FusionServerApplication.class)
//                .applicationStartup(new BufferingApplicationStartup(20480))
//                .run(args);

        // 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章
        // 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章
        // 如果你碰到启动的问题，请认真阅读 https://fusion.example.com/quick-start/ 文章
    }

}
