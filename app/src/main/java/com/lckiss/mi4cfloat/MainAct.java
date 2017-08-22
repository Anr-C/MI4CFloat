package com.lckiss.mi4cfloat;


import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Looper;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.widget.Toast;

import com.lckiss.mi4cfloat.widget.ClipRevealFrame;
import com.ogaclejapan.arclayout.ArcLayout;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainAct extends AppCompatActivity implements View.OnClickListener {

    private View rootLayout;
    private ClipRevealFrame menuLayout;
    private ArcLayout arcLayout;
    private View centerItem;
    private ExecutorService cachedThreadPool;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        rootLayout = findViewById(R.id.root_layout);
        menuLayout = (ClipRevealFrame) findViewById(R.id.menu_layout);
        arcLayout = (ArcLayout) findViewById(R.id.arc_layout);
        centerItem = findViewById(R.id.center_item);
        centerItem.setOnClickListener(this);
        for (int i = 0, size = arcLayout.getChildCount(); i < size; i++) {
            arcLayout.getChildAt(i).setOnClickListener(this);
        }
        cachedThreadPool = Executors.newCachedThreadPool();
        isFirst();
        onShowMenu(arcLayout);

    }

    private void isFirst() {
        final SharedPreferences sp = getSharedPreferences("key", MODE_PRIVATE);
        Boolean isFirst = sp.getBoolean("FIRST", false);
        if (!isFirst) {
            new AlertDialog.Builder(this)
                    .setTitle("骚年，第一次吧！")
                    .setMessage("第一次使用将释放配置文件\n" + "点击确认即可\n")
                    .setPositiveButton("我知道了", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            cachedThreadPool.execute(new Runnable() {
                                @Override
                                public void run() {
                                    doTask("", "Conf");
                                }
                            });
                            sp.edit().putBoolean("FIRST", true).apply();
                        }
                    })
                    .setNegativeButton("我拒绝", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            sp.edit().putBoolean("FIRST", false).apply();
                            finish();
                        }
                    })
                    .create().show();
        }


    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {
            case R.id.center_item:
                cachedThreadPool.execute(new Runnable() {
                    @Override
                    public void run() {
                        doTask("open_six.sh", "六核全开");
                    }
                });
                break;
            case R.id.menu_one:
                cachedThreadPool.execute(new Runnable() {
                    @Override
                    public void run() {
                        doTask("power_save.sh", "四核省电");
                    }
                });
                break;
            case R.id.menu_two:
                cachedThreadPool.execute(new Runnable() {
                    @Override
                    public void run() {
                        doTask("drug_v5.sh", "有毒V5");
                    }
                });
                break;
            case R.id.menu_three:
                cachedThreadPool.execute(new Runnable() {
                    @Override
                    public void run() {
                        doTask("auto_four.sh", "智能四核");
                    }
                });
                break;
            case R.id.menu_four:
                cachedThreadPool.execute(new Runnable() {
                    @Override
                    public void run() {
                        doTask("just_fun.sh", "智能畅玩");
                    }
                });
                break;
            case R.id.menu_five:
                cachedThreadPool.execute(new Runnable() {
                    @Override
                    public void run() {
                        doTask("auto_six.sh", "智能六核");
                    }
                });
                break;
            default:
                break;
        }
        onShowMenu(arcLayout);
    }

    public void FinishActivity(View v) {
        this.finish();
    }

    private void doTask(String file, String model) {
        try {
            if (model.equals("Conf")) {
                ExtractFiles();
            } else {
                InputStream is = getAssets().open(file);
                int lenght = is.available();
                byte[] buffer = new byte[lenght];
                is.read(buffer);
                String result = new String(buffer, "utf8");
                shell(result, model);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    private void ExtractFiles() {
        try {
            //挂载系统读写
            shell("mount -o remount,rw /system", "Conf");
            String datafile = getApplicationContext().getFilesDir().getAbsolutePath() + "/thermal-engine-8992.conf";
            InputStream is = getAssets().open("thermal-engine-8992.conf");
            //读入原文件
            int lenght = is.available();
            byte[] buffer = new byte[lenght];
            is.read(buffer);
            String result = new String(buffer, "utf8");
            is.close();
            //临时写文件到data区
            File file = new File(datafile);
            FileOutputStream fos = new FileOutputStream(file);
            byte[] bytes = result.getBytes();
            fos.write(bytes);
            fos.close();
            //更改权限
            shell("chmod 644 " + datafile, "Conf");
            //复制到system区
            shell("cp " + datafile + " /system/etc", "Conf");
            //临时文件删除
            file.delete();
        } catch (Exception e) {
            System.out.println("Sth Wrong with copy .conf");
            e.printStackTrace();
        }
    }

    private void shell(String cmd, String model) {
        Process process = null;
        DataOutputStream os = null;
        DataInputStream is = null;
        final String TAG = "V";
        try {
            process = Runtime.getRuntime().exec("su");
            os = new DataOutputStream(process.getOutputStream());
            is = new DataInputStream(process.getInputStream());
            os.writeBytes(cmd + " \n");  //这里可以执行具有root 权限的程序了
            os.writeBytes(" exit \n");
            os.flush();
            process.waitFor();
        } catch (Exception e) {
            Log.e(TAG, "Unexpected error - Here is what I know:" + e.getMessage());
        } finally {
            try {

                if (os != null) {
                    os.close();
                }
                if (is != null) {
                    BufferedReader bufferedReader = new BufferedReader(
                            new InputStreamReader(is,
                                    "utf-8"));
                    String line;
                    String s = "";
                    while ((line = bufferedReader.readLine()) != null) {
                        s += line;
                    }
                    if (s.length() >= 3) {
                        if (!model.equals("Conf")) {
                            Looper.prepare();
                            Toast.makeText(getApplicationContext(), model + "模式切换成功", Toast.LENGTH_LONG).show();
                            Looper.loop();
//                            //延迟一秒退出
//                            Thread.sleep(1000);
                            MainAct.this.finish();
                        }
                    } else {
                        if (!model.equals("Conf")) {
                            Looper.prepare();
                            Toast.makeText(getApplicationContext(), model + "模式切换失败", Toast.LENGTH_LONG).show();
                            Looper.loop();
//                            //延迟一秒退出
//                            Thread.sleep(1000);
                            MainAct.this.finish();
                        }
                    }
                    is.close();
                    process.destroy();
                }
            } catch (Exception e) {
                Log.d(TAG, "shell: " + e);
            }
        }
    }

    private void onShowMenu(View v) {
        int x = (v.getLeft() + v.getRight()) / 2;
        int y = (v.getTop() + v.getBottom()) / 2;
        float radiusOfFab = 1f * v.getWidth() / 2f;
        float radiusFromFabToRoot = (float) Math.hypot(
                Math.max(x, rootLayout.getWidth() - x),
                Math.max(y, rootLayout.getHeight() - y));

        if (v.isSelected()) {
            hideMenu(x, y, radiusFromFabToRoot, radiusOfFab);
        } else {
            showMenu(x, y, radiusOfFab, radiusFromFabToRoot);
        }
        v.setSelected(!v.isSelected());
    }

    private void showMenu(int cx, int cy, float startRadius, float endRadius) {
        menuLayout.setVisibility(View.VISIBLE);

        List<Animator> animList = new ArrayList<>();

        Animator revealAnim = createCircularReveal(menuLayout, cx, cy, startRadius, endRadius);
        revealAnim.setInterpolator(new AccelerateDecelerateInterpolator());
        revealAnim.setDuration(90);

        animList.add(revealAnim);
        animList.add(createShowItemAnimator(centerItem));

        for (int i = 0, len = arcLayout.getChildCount(); i < len; i++) {
            animList.add(createShowItemAnimator(arcLayout.getChildAt(i)));
        }

        AnimatorSet animSet = new AnimatorSet();
        animSet.playSequentially(animList);
        animSet.start();
    }


    private void hideMenu(int cx, int cy, float startRadius, float endRadius) {
        List<Animator> animList = new ArrayList<>();

        for (int i = arcLayout.getChildCount() - 1; i >= 0; i--) {
            animList.add(createHideItemAnimator(arcLayout.getChildAt(i)));
        }

        animList.add(createHideItemAnimator(centerItem));

        Animator revealAnim = createCircularReveal(menuLayout, cx, cy, startRadius, endRadius);
        revealAnim.setInterpolator(new AccelerateDecelerateInterpolator());
        revealAnim.setDuration(60);
        revealAnim.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                menuLayout.setVisibility(View.INVISIBLE);
            }
        });

        animList.add(revealAnim);

        AnimatorSet animSet = new AnimatorSet();
        animSet.playSequentially(animList);
        animSet.start();

    }

    private Animator createShowItemAnimator(View item) {
        float dx = centerItem.getX() - item.getX();
        float dy = centerItem.getY() - item.getY();

        item.setScaleX(0f);
        item.setScaleY(0f);
        item.setTranslationX(dx);
        item.setTranslationY(dy);

        Animator anim = ObjectAnimator.ofPropertyValuesHolder(
                item,
                AnimatorUtils.scaleX(0f, 1f),
                AnimatorUtils.scaleY(0f, 1f),
                AnimatorUtils.translationX(dx, 0f),
                AnimatorUtils.translationY(dy, 0f)
        );

        anim.setInterpolator(new DecelerateInterpolator());
        anim.setDuration(80);
        return anim;
    }

    private Animator createHideItemAnimator(final View item) {
        final float dx = centerItem.getX() - item.getX();
        final float dy = centerItem.getY() - item.getY();

        Animator anim = ObjectAnimator.ofPropertyValuesHolder(
                item,
                AnimatorUtils.scaleX(1f, 0f),
                AnimatorUtils.scaleY(1f, 0f),
                AnimatorUtils.translationX(0f, dx),
                AnimatorUtils.translationY(0f, dy)
        );

        anim.setInterpolator(new DecelerateInterpolator());
        anim.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                item.setTranslationX(0f);
                item.setTranslationY(0f);
            }
        });
        anim.setDuration(120);
        return anim;
    }

    private Animator createCircularReveal(final ClipRevealFrame view, int x, int y, float startRadius, float endRadius) {
        final Animator reveal;
        view.setClipOutLines(true);
        view.setClipCenter(x, y);
        reveal = ObjectAnimator.ofFloat(view, "ClipRadius", startRadius, endRadius);
        reveal.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                view.setClipOutLines(false);
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        return reveal;
    }

}
