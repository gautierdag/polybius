��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qX?   /home/lgpu0444/diagnostics-shapes/baseline/models/shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XJ   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   64880160q7X   cuda:0q8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   64593920qCX   cuda:0qDKNtqEQK K�qFK�qG�h)RqHtqIRqJ�h)RqK�qLRqMuhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqShh)RqTX   trainingqU�X   in_channelsqVKX   out_channelsqWKX   kernel_sizeqXKK�qYX   strideqZKK�q[X   paddingq\K K �q]X   dilationq^KK�q_X
   transposedq`�X   output_paddingqaK K �qbX   groupsqcKubX   1qd(h ctorch.nn.modules.batchnorm
BatchNorm2d
qeXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/batchnorm.pyqfX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qgtqhQ)�qi}qj(hh	h
h)Rqk(h2h3h4((h5h6X   66225408qlX   cuda:0qmKNtqnQK K�qoK�qp�h)RqqtqrRqs�h)Rqt�quRqvhBh3h4((h5h6X   66224224qwX   cuda:0qxKNtqyQK K�qzK�q{�h)Rq|tq}Rq~�h)Rq�q�Rq�uhh)Rq�(X   running_meanq�h4((h5h6X   64567280q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   64558432q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   65000640q�X   cuda:0q�KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XP   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   65742608q�X   cuda:0q�MNtq�QK (KKKKtq�(K�K	KKtqh)Rq�tq�Rqňh)RqƇq�Rq�hBh3h4((h5h6X   64552736q�X   cuda:0q�KNtq�QK K�q�K�q͉h)Rq�tq�RqЈh)Rqчq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�hVKhWKhXKK�q�hZKK�q�h\K K �q�h^KK�q�h`�haK K �q�hcKubX   4q�he)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   65187952q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   63357408q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq��h)Rq��q�Rq�uhh)Rq�(h�h4((h5h6X   65330096q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rr   tr  Rr  h�h4((h5h6X   65751904r  X   cuda:0r  KNtr  QK K�r  K�r  �h)Rr  tr	  Rr
  h�h4((h5h�X   65307152r  X   cuda:0r  KNtr  QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   5r  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr   hh)Rr!  hU�h�G        h�G        h��ubX   6r"  h+)�r#  }r$  (hh	h
h)Rr%  (h2h3h4((h5h6X   65012992r&  X   cuda:0r'  MNtr(  QK (KKKKtr)  (K�K	KKtr*  �h)Rr+  tr,  Rr-  �h)Rr.  �r/  Rr0  hBh3h4((h5h6X   64007888r1  X   cuda:0r2  KNtr3  QK K�r4  K�r5  �h)Rr6  tr7  Rr8  �h)Rr9  �r:  Rr;  uhh)Rr<  hh)Rr=  hh)Rr>  hh)Rr?  hh)Rr@  hh)RrA  hh)RrB  hU�hVKhWKhXKK�rC  hZKK�rD  h\K K �rE  h^KK�rF  h`�haK K �rG  hcKubX   7rH  he)�rI  }rJ  (hh	h
h)RrK  (h2h3h4((h5h6X   64820112rL  X   cuda:0rM  KNtrN  QK K�rO  K�rP  �h)RrQ  trR  RrS  �h)RrT  �rU  RrV  hBh3h4((h5h6X   63462976rW  X   cuda:0rX  KNtrY  QK K�rZ  K�r[  �h)Rr\  tr]  Rr^  �h)Rr_  �r`  Rra  uhh)Rrb  (h�h4((h5h6X   64464624rc  X   cuda:0rd  KNtre  QK K�rf  K�rg  �h)Rrh  tri  Rrj  h�h4((h5h6X   65204320rk  X   cuda:0rl  KNtrm  QK K�rn  K�ro  �h)Rrp  trq  Rrr  h�h4((h5h�X   65285200rs  X   cuda:0rt  KNtru  QK ))�h)Rrv  trw  Rrx  uhh)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   8r  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubX   linr�  h)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XL   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   64986896r�  X   cuda:0r�  M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   54337664r�  X   cuda:0r�  K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubuhU�ub.�]q (X   54337664qX   63357408qX   63462976qX   64007888qX   64464624qX   64552736qX   64558432qX   64567280qX   64593920q	X   64820112q
X   64880160qX   64986896qX   65000640qX   65012992qX   65187952qX   65204320qX   65285200qX   65307152qX   65330096qX   65742608qX   65751904qX   66224224qX   66225408qe.@       �\�= @�=��L=�C>�1�<��>��v�����A��=&~���=m3+<�.k���_=!>�����d�="�&=X~�<��=S�,>���<S��<�D���<���=S�>��@<�[=�9Z=|"��6��<��
>y7�=���=L�"��/�=��=Y�������*>�M�����:eHX='Z.��2��j�=1�:=�/=��<(њ�I�<���7>}�>��<e���tͼ�&�=t�W���u=����Q�=���=�z=       `�>.��<c����d5>�9���>�=X�,=�Ѝ;���=c<@�=L�=��#=t�l<��<š-=%����X�vcr<O�,>       O*=T�=���=�ԣ=�l>��>�H�>7��=��=��N>xe��S�>��>�+�=h#�=�%>%F>�d1>���x1�<       �T�C�L=���=j��<��8��i	��*�=.ޔ�gOL��Ђ�o�f=��<Q\񽴽>J��<��=Td��ټ]n�=��̽       ^�ο��T�1��������uN¾�d��Ҽ� :*�S᷿E���L��+�>T�ƽ?��8T��%</?$���F�"���       �=��5��>���R����60>��&��KFýU�T��8��;*>($F����=�)ۼ(y�i:<2���9u�<�6��       �;!<�v;�`;��;�l6;!ѩ;,I�:e�y<�U;�t�;��;;R�;��S;�h�:�(<<U;?��;i
�;��+;-J�:       ���iq=Zvt�z%>�j��Ew�=��>��K�n�˽�V<|)-�p��>�j�=Ҡ��72�#̥<%����>��Fq\�       ��х�=6b��->��4�'��=hQ>ՖK��6��5�<���`�>��>�8��z�5��<
��l9�=���^�W�       ;��?k��?�N�?�l�?�?w��?Ս�?�t�?e�?�?�Ù?���?L��?F��?hc�?)��?o��?�̤?괏?�a�?      ���<���7�=�U�o8>��z>�*�< à>0�>J��=�8�<�[S�#-s=7�i���5�#�P�����#<�N@�T���9>W���mH�R�j=�^�=��=i�=��d=�ļ=Q��Ü�;]jའ�6>��L� �ԽGM��pt�o��>�����.G��@ｙ�0�0	���C�c@'>���+�=`�I��:E>�̓��
\��3��{�_=~ ������"�� �=����(���� >��,����;1�=1Aý�[�<�� ��ؽ�ĩ��dj>����Y���P�=ޠ��'�>�0#�vý[��=���=�N���� >��<������:��:<P,>"����<������I�*���D�=����� ��zE>�&���g<ź<�����cd=�a�;��<{T%>�R�5G<i����y�����<_�of�=d�E>��彫g ��[���,�=`c���_�=gD����
>��=7������X���:(=6�ʽ�?I=�S�=�j=��D>b-�S(P�c�P��Ǖ=<���H�<w{�=
�<>;$��^�]�=J�L������"׽1����
�ݲ8��L�> ��=2P����i>
v�=�ɪ�F�=��m�����=�I=N���@>���<�l>���<9"H=�~�=�-p�Y�Z��e�>R���B'���P����;��9�O��W���)>��%��=཈]�r&�p�ν��>9�=�����$�1s�=��<(���	��=�/�>��=��f�/���4�>=,&>�K�=��D>	�=mW���<5�h�B���=�|��t�+���5;������ƽ)�N�����:��n<|Q"> ���F�<�p� �>};=|G��Ͻ� >Y�ؽ���w����)�7T��I�$�╬����Aj�=A���B/�>��۽�p���7�N�K<�hH���i��0>kE�=n=�m�=ZF��˽�V��3�c(�D�NI1>rI=�?>C�Ƽ7�y��I�>����v�]���u*�<r��;��=ዽ�7h��T>�i=�KN�̵)�1>��>)���ԽW��<~�t�$�M>�i����>P�.ߦ�3��B�<��9=�����X��,~�4�����Y�G��wQ>u����>��>̨<��>���=O����=K7��(p���$��4��=gO��ڷ\�K�>�RE��s�=n�X���m>7r=>�`>a�P;R�;�9�p�r<n
���S���Խj2<�1�����۽��-����
���7&�=V\�u���|�>_`�l.'<��/U|�I���~j�~�L���h���6�!���	 ->M����>�(����Y����=uO�^_3���׽M�_�-���Np0>�,��[`��g�I�N�1a>����>�{��r�>���6_���=��=Z��b�Խ��=��ػA�a<�!��4z��>m�@�s�H�g�?O=�I=�6ɽ=df�N�c�ɹq��	.>�;���=�8f=s�=A�*K�=B��Ƀ$��v���ּ��A=I�=��Z���=#x�^�$�$2�\��<�lP>g��=�����뽲9;��#��N���e�=V|�=�C=#m,��>�5>g��Uj<rT����=)D>e�ɽ��=��+�����5F<�o����F=+#�>�-t<M�뽁W�=1s	=d�t�g���֐�+��=��>#����v<�75>�����ZK��ަ���=��=�5=w�<ǹE�
>�ċ=<�\=+��=��8>Y�``>7u	>D��쮽��=Z�<>j|=Bq�<�;�>��>�t)>�H������*=N<V���w �=�َ=-T>Cx�;�ذ�h��=���=��=A �</a>�93�����0>�g/=�b=���=���=j��=Y0��B3����ֽ�����u���B��c�B��w@�>vD�b�J�����:=���=�x�=_1�<c6q����X)-=L_)=x��=�T:���'>�)�<�>�BB���<ퟛ��4��Jh=+�1�"��=�˵=�K��c��=#�ӽN�>���=�̣=m���d�:��.:���y��V=ڥ�=&�5�Kh;>�:�j��O�<�k��#��/��=       BM�&��>w,����)*���x>݋˼�S���H�T���߀=X�Y�MD����2�c�<�e=>׽��+��V��H=��i�_�L]Ͻ�`��S2���>�s1��=�P��= �U=��=���=@�ͽ �>y%�yɄ�����t><h��F���ֽ�ھp#�l�B=�?���i8*��a�=kP�=�󕽊(�==uԼj|ʼ�Iw�ُ=��j=���=�h4>ie�<�?�=g����B�=�¸�Bv�;5m=ן���=���(��C
>��~�y�(�ȋ��Ӆ>��"��s=���4�>��yl��P�V���1Φ= ?�=Lg��
>a�o����N>�\c�|bC=lɢ�wG�=��,>�0���R��48>BW<�o/����=@m�=xw�<����&S�=��$��f >��Y�)�\��*�M#I=�e^=�=��R�@x3=6ւ��4=��>�G >��u�Gu=���=�.�u��<��0=|�H>�X[=�&�=��=� +�I`�=�}�=˚g=,'�s�ͽ9�=w��=Z�J=W�W<i]������/�=5酽	�|���=գ��sF=:��RE�R��=��?=�J��O�<>�>��_�s��#=$��=%\���"�=]¼�饽6rB=���=W�����=��o<6���D@>�����X>�� ��=1߼=H�0><�=���=k�L�{4�=,쬼&�[<�L��_<=��ż6���S4=����f=�-Q����=����<f�=�"?>�
�<&�)>�R����>�~>�>>>�ͽ��X=z�=.v^�cຽ��F�V�˼��=�~�9>��v>��7>\ԙ=j>Mx>V����>��	��i�=%�ν��f=��g>�ͻS
�=�.���>���>,�<c�>*��V*�zMk=G����=w����3�=vv���,>������1<d���~8��p>	W�اC�-'"����������曽��>-�@=��X��,l�>Л�=b����=��l>�:#�ϐ��� >;�!�v������)��=��һ���c-�mbu=n�F=���=^|��Ro�G
"����=��m�:F���C�>�$�=���="������hAý���n��= ��=�����Yj���9r�i�>{p�=61�:��<8��=����P�=�����d�B��=��c>���>�2�Ν=P[��!> �e>��=���Z�
=靾y|��	k=�L>,�;4e���¤���;>�ꕽ��c;.�f��K�=��^=��m=9b===˪>��=� .>��S:ˉx>�0�9�>��@=�G�=�ZO=�ɗ���>y:5=e���X=s���~��<��I���ȼ���=���=]�đ*=u9;iv<ڧ��N
4>�J	>6R>g�T��+�=ON>��5>I��I��=&�k�aV���̽8><���=j>_����=��f�=�T>N���?��"�=�v�E�=���=�oϸ�;z�?)�=Ę��
 �=tO�mX=v $��/�:�z�Q=Q�=#��>+�B���=�S~���>!ͽCz<B���夼XO�����L6�=a��=�"��&�pMF=] +>�Tw=j+>3\��l��=���=E�d=���=�`�=���<�|��)<�vn�3>�<���k<y+|�c�>[���E���o=�l8�D�Ӊ�=,?4>���=�������>�3�������G>715��=�x:�,�=О�=g_y�Y�����.=�|�=2�Y=&���zP潕x���q3={ꏼ�G�=��+>�&�=`�=����!J|�'_׽�
�=E->�>����h4=/����>�����=8�6�a"нH�s=I��������.ɽ14_����P'��R6��Ϗ=�e=�"�=��9�V���jH*=D��=�0�=F�G=��*�����S��`<�]#>�)>�%i���=����� >���=IX�=*�v��Uq<31���=�]��	���ϼr��=��v�w���z��ýqU�=s|�=�U�>�"g>b簽]
	>�|�=�m�=~c�=Z�����=l�L��RB=b��=��K��C���<�9�=� ½��=s9�@ib��s�=�+!�.V[=(.�̚�=��ݻ�֮=n?>��=�,�O�H>���A�J�Y�=�ż��>Pڿ�O>F�X�6�=�
&��Ĉ>��=>�<.��M> k<������O>��������=F�>������[�����,=�>�� ܽ=�����>��U���>NAh��$�����=��=��<�.>���ϱ�>�F��*�>Ŋ=�{�>�k{=w���J==�8=I��<�͍=�ɨ�W9>1ù==��<��=�V�>U���ҝ=Qq[<�8C��Yf��P�=���<���9�� j.>�2�� H>Њ.�X3>�Z���<L�7�B=짚>	!S>L��>��=�����6�ս��H�^�8=ρy�e�ͽ�<`�=�T�>5
�=��=���z�=: =q����$>O�<>RA�n>�@���m>�x�=m)�y��	>i>�G����"<=����)����<���<�̌=���=X����>�EI&��=��f�=��m�N�h>��>��M=����B|>AW>��������S=�rb��o���=�X,�S�����<��=">:1>Q���Jm�jp�=��<I��?����=�w��"�=�F>H�<P�>�r5>b�=$e׽2[r=ƪ!����;l4<����T<�0�� N;�4��[�>��X>�^��-��=�4!��~{��"��ݼ�k3�c���rW=�A����ɼ�֊�f����V�<Ϗ�=6���Iq=�����>�S}�D�c=p�/��8Y�\�U�?�%>o���O�=�g���=���t`��y�=����q��qW>��=�yI�S=��
��=���n�Ͻ��>��(>F�=�� �<�Խ�b=�<�)8�m���x1c=/�1��Ҽ�u�@�.>M�=3A��fH�+Ʒ=S�=�B�=L�W��.��6GR�_�V���_= �=�47=g���=f>�ܽ�7=�L�=w��=�vD���=���O��>Bï���y;�3)<�^>�ʷ�:A�<B��r���F��J�=�$�=��=�a�=	,�<�;�)G����''�>P��S�d�)�4?��*j=˨�<%:̽ʋ��/�<!D�;i��������<2�=��R��,��g=Hy=��P=u�<�!$>��E=��{� �6>v���6=@�f�3˻=�CP�y�}��݈=;W.=�q��3U�G~���=�-��� <b�=<�;ٽ��=�1ǽ����!=�$���R=�=�Z�vY����1=�)=��d=�h�=�=	ս�H���p=z �� �4X!;�;��n_����D>�Ώ=�S8>f�=wn���G�=Tz�=@��=3f}�>�P��G�5<\De�g� >�!�7��>i�<���=x�E=�9/>U.K=2�Q���=�� =\��pM=*G�=x�=��0<|>�>"Z���=)2w�p�
����=P/�Y�=ݠu<^��٧<��:�<���>��=Ӝz=S���K�*��h��=������=b�����8����G���h=�>#@�z;�=�I�;ί=K!,>p��<SN ��S<�ػl��i�G,7=�;�
�]=cZ���H�=";=��^�c�������=CX]=[y�<��>���<K�>^�8�z�B=����o��lT��O��oŽ��)=C<���+�|�7��-C>��^=�ŏ���X��->�=����&�=�ýx��{;ɼ�ܽt�6=FO���x<>�<�� ��p��A�=h���&>u�x�H�>�u��BL=���<���8�����Ŗ>O�1>J��!�4>Y���=?gn<��[=K�=��*��g7�F�&��Y��O�_>��>v�P>��=+��=�}���=;]����-�"2��	L�K���F��u.<�*b;���=���e�6>���=������	�����G>���ĥ���r潠�켝7�cI�<�E�=w��=�j<���<��4=E"S<d��=*� �����|����b�%� ��x����G;M3;s�E���=�l���R�=�<Iҿ=���<-�%>8�:��z����A=�:>O�=��=��h>��>)˽>��=㺴���b=o�=��<�h���e��">Y��=��=��2�����z�=����cG=���=*��^{=K+Žή�>v��=ǃ��Tk��R>wdX=��/>��=zVn<�JýzF3�L�<�X��{���U>rs�=!2��3�=�S7>��<C��O�M>̼/=6�m��H�<� O�)7��.=,�Z��0Q<��u<Yd=��#�_�0>?�.;r��=�*+=*�]�����Ǥ���[�=iо�q��=cĽn��>X���q(>�Q����%� �<̛�{��Oo=���3�������@=�,��?8=2"����*B�=�S2��m=>�X��(�V�Y�=='��=�p�"��<����̵=8�[�\��7�¾�<�<������н�>��X1�<�{J��^ƽeŀ���Z=��=HD�=4�o=���<->��=$A�=��=#��=\��=��SM�=zs	=i ��S �=�4�<��8�W�<>Y�<}�=m3Z=���8=�5�=і��I�=��>�p�������9�ť>e��.�P�V�	�B>��=�R>]� 2�=rz@�f͝��]���=d�ԾM/B�:���O�;��q�}��vj����=�9��:����=U����yN��B>�[�
�Ծ��s=?.Ѿ����
O�<zRҽs�M>�;>��9o=�^�����9��ս�Q��<��[���z<��<�n�<��=��9=��H�n�b͘=T꨽0���>�n>?=Vz�Q���iL(>}�=��6>۾�ƽ@X>;9>N�;�"V>��r�=J�J<&�/>~]/����Y,>��.���=ZK�=,�B>Ք��T?�XH��$>�N��V�2�� �=�Qe�9��=|6��vǣ>��P���>g���>��E�5��q=u���Df���b����;�=13Q=�뾼:��<K騼	�>�'��1�=(����!�>	t,�ģ�=�������9>-���z<�x��\E>Y@��&�%M����<�L���Yc� �<ht#>Fn��O��=����|*�A����+==��=��|�R�Ѽ��4���'���8Q��<�'
��l�pU�;���=���d�;>(�ܿ�=��?>q�=�Yp>��)�E���V��>�x��P�>7��=ء=p �Hw�=!1���=� ֽP�>�N�=���]����g��}9=};��I0�<�N޽�;=5X�<�:��C4��$�=M�2>	�=��<� �=��j�������\=��=�K��JL;������=�|�=�ͽ�Sϼ��2>?O�=��=��=���=۟�<����;V&�g�;�">�p��x�����=��=;���mU>��/>�L�=∩��y6=�O]=�qԽ| =2z�=�i�=��=�G�<(�=�6<�Q2�1�=`�5>�8��d_=}4�� ��=�<܂�F 6>��|���C�8��`�>���<:X�=�w���F�<cd<������<Y��=�������KP佐l����=�Ʌ=B�=+.�=kaa>+���B{8>���<l�>�K�=%B.>�	=��v������6��tq�EC�<K��=����$C��kD���#>�Q
>|��>���0ܽ�.4=C�<C��=ܩ=9>�Y�=�N>�T�;�|�=��>�𹬼#Vh<�u��_=��>%����+:=�VT�Og�=T>佗��=Q:h�Ac2����LJW=��3<Q+v;�����,x>W����3�fl����=�%>�1��q��=(8P>} ��iV=k��= ��=�@�=
tP��H�=i�<���\�>������j��<��=W���X��<ՐW=���=�҈=Tf7>��Q��>�Ϟ=\X-�6q:=g�ռ$�E=pG�=�$����=��=��<��|=H
S<_G�=99>���=Je�="��;t\���= �3>\O���c�JZ�P�u<:$9��=w4мD5�=q�J�1�;�>-�����e>]��=f+=��>�9:=҉>	,�<Y ���9�=즞:��=��H=e]g>W�>�K��6ߋ=��=K���p����˽��ۼ|��=3���z=2�>>8�3��#·=x��<�0���<>j�J�=MZ�=�î�{J�;y�<̓0>C���o�]>+�=��]�x�:l݉<M��E|;2�|��Ѽk���y�5�U��J=�M}����н�CT=dX��U֑=�©�Fv,��b������� �ݺý'-ʽ@��=�a	�����ж���.z=%0�=i&>2���=��7Ѽ��˽��1���.��*=`��n��?�߽(���i�>��=G;�;Ce%<�d>�d���.=��=���#7&< Ht��5<=P�N�r2�=���A��=R��E����>v��=:�+�s�ݽ�K3;bà=��=���=�����=@�@
�=P�B����=^pػ~��>O8o�k><c�%���q�L�ǽL=6^��-���������2>��>���B=����{�<���Z$=B����=�P=5t=�<��ǵ	>̝8���-��8I��)$>��ֽ*>Ρ�<<�|�х��jL7>fe�*X�:��J=���=@��=Oy��/3-��]ܼ2绎�9��.ݽ�5��5��=A�=H*M�o�C=���=ĵM=��>��<-���`ҹ�ֻlSv<ᄻ���=_Y�l��=�Ƽ�̶��x#>1=G�=����F��Q�=��{=%��=~v�;���=�Sɽ���訆�?P>�=+��3/��½�<?暾<
q=�w=���=�U�=����>>��l=���<��S�	�>x>Z��=*�>>#��<��s=��=`�">&�?���i�6>L�8�X�=qh�|@��A�
��<�����$�=[7Ͼ��|>[<Q�#Y=�	����=`\�`�b�k�=������"�Ѽ�L�=���� �ѭ=�mL��3>NC��:�=��c��C�S��<��=����n���^�1=M��zpJ>ok9>���<F�u���>�%��0�<�">_'Ҽ����ъ�3���d>k;<(v��2=�V�=W���d�XÀ=���=�P<r��=��I=@�����=���>���=��-=O��=�[>��=��ѽ�z��Se=��ý#8���r-<u��=�s�=��=N�����۽�H�>�;�=�1<O`�>��=�5f��j
�kj���=�h�>8�;L?o>�>���=>��= ��;�%��ω<��k�G/�+�$>
�=�q��y��:��Խ��R�Cm��I�I��ʖ=z�0��f>� �=L��=n��� �G+O>�C�<">�8�y�`�r��<�B�������W����;!�=��5>m��=:�c���B>�#<��D��%�=/��=�-�>��	�A�����<�6мu�<bq�=$yU��K�=Ä�  �>(`=�̣<�tƽoc�=�Cd�D���� �,���	=6��_�׽��d���=�n>6��3�H<���<����0�������y���(3�'�<�@���2=�pj��
>w�Z<�N=콰��W��(̽g�>C��s�=!Ƣ=>Oz=���{����=~�=�M7>��>� �ʊ<=H��=%��=�mq<�#���Xý��ʼc7�=����\<V�<�.Kg�U" >a�=��=�[=�H�<���u��<� μ��>�:0��)��Ľ������e,>�G�>�JF��Σ����<��<��={ὰ��<��s�dt�<晦=���=����>B�ռ��ͼO��o�=�2{=�YL�ʂս �=�l;��<��N�'��=�Z�<_���<J�=���=ɺ������1�>j����PZ�x�ڽ_A>�����P�\�0���R��^">���)(��s�=�$�=�yN<$��*,�I�I=3^�<�[��'P�����<UA�E�(=��M�\.�<9�7���/>��;=3}�<��)���"�T=4	>ME�<��!=!e!>�R3>]�9:��I<������<�H^�7>��=��=��i>a>>���3�B>����y��<�n���ƫ>f�L���>���ѺQ�½�F��������1�=n4ѽ�u=�c#=[���:.���h�=I�=�D�+���r�>�dO��q�>{����<�"=
�=u�]�Y`=U��;��>���=�RT>s�p����Vl��v�=�=A��B%��mD�˲&>��<���E��k�
�>�>"a-�#�L>�Av���=�
�����J>0Ȼ������;0��a���kAG�Q>V�G=Z�[>q�= 9νzKd>�o�= ��`
m>�tվZmq>��}�,=���;��->� ��4�H>`�=�vx>���<I\L>��<>h��>O#�)V6=�"��g��S�$��	�v��>h�O���ʾ��x:����Z�=F�>ϵ>s�>���<B��=�XO>vbp>�p=ys=W껼���q�����=��;���>qĽ`Ƚj�;,�n�V����N<��1�]�e�=�GH>oޖ=�9�>V�;=�#t=M>K�=kg�=M�*=d.h>��=�W�U�'��>�+5>�j>C%�'�>KMe�h�=;�>���=���=]�<�Ŷ�5�=3;�>%��=�,e>��O>q���a+�=m��=Fv�={}T��=n�=C���&c�Y�нR��k>E��vH=y���.>�1>�W�l>�l�;���=啒;��u=)�K=�<�=� h=�;>P��<ZJ0=�;>0�	>�]�=wk�=Q��<̯�=A'���e�=:5=�>M 9=�1>�Ϯ=	����=�͌>\�=�9>��=���=�� ����X �<���9U0>V$>Z}1<U�>��>#F�=��=GL˽���<{r�<�O=p�e��<��")>'�;�r�<��>u#Ӽ��R��/=8�o����=�_d�m���4U�ؠ�<'�=�7�=����ͬD=�PZ=�p�=tw"�	�+=�í���YnL�?�%>~�f=��ڽ���U>��IF>q���I������O� �
��<Z�#=�9���P���-�=;�=}�8=gսl��;]q�J��<&8����r��}����0>_0i=Zj���=����Z��!�:N@>����>8<z��t!<;[ѽ�@�I��=F��>���� Z�2���Xk����=3�� h}==�#�|��=Hz�=VlP������R>�C�F+żZ�=\���wXѽ�e�+#=���<<b�>l��LK����=\�=��Z=�nG>ޣ<A>����?3�;'W���">�H>���<�ڽ�wg���μ�� >4E�= 4%���=3���=�ǃ�(��<��#>>P�:T`X����=%r
�e�н�ڴ�9����T�<��->F�='@P�ڠ3>��=�ׁ=w�=����un�=�X>�'=J("<��=��Ξ;�f���>��[<�U��΋���=6�g>�kR=�fk���~��#=�����	x��&�=�a�=k׼�W�=n��=^����Ӿ>��<�>�W>A9>G�>�1�=��>��=�T��krF=;��<�&#��nF>	h^=\Ć�;�>�(=SV�ܓ�;>O=Y|�T��<%5L=�y2���"=?S!>�(>�^���ͻ >r�d>�:+=��㽭�7>a;�=D��=��:��=ְ=y�=�&�<:!>��=Ã%=h��
�<U�=���=1�=?M�=;/>Z��Kjؼ{ �=����\=C��=�*�=bh>����t-!�5�=�s
=`��=��0=�V�PI%=�J�=����B�>+b6>o+=�н��>��=ٸ�=�>��4�ì�<��ǽ���%�ڽ��o��k�B\Q=���=��4=�e=Ρ¼pZ�L�̽W�=�Fļ
�B������J�;j��ʢ	>ob�=�Ι�}=lC����=^C�=�J�=�����2�����]'>@.�=2x+>���9�R�O��=���%�뽳�0���=�L�=<�?�{�Q�hu�K��=Ȯ�����=�D�<��^�H�ֽ"nj�/��=�cͽ�ǽnO޻B�=�����f�3>��E>SV��`��>�(��P���\�ʽ���eh>�F��"�<H��j�=~T�-����ޝ=�2>�z�=�xٽJ��<@,ǽB��<�%�?v�Xۏ�Ent:v�=�9�=1/*���I�>Y�<=+�=Jn�=���<�U>�jԽ���=���=2
�=�d�=���=4|ȼv;�<��H>�Z�=t�}��x>$��=��>e���>l��=7F��c��ݤ=�r�
>�䭽g�½2���ȟ�{q�?��=Vb�<�n���(�m��=m&>o�5�></������)>�}s��&����f�)g�=عT�6����R =Ӂ�=W�C��g�� �~����b����f��Jb<�>]6]��z��.�u���������k���＾��=*���Cǽx��=��T�*5����=�^�[9-=�:�=�����5�TCݽc"���>?��=u�>��/,�񕢼���=l���{�3�%���F�a���.l���k=�w�	^����%�4?>��'����G��z�=��ڽN�>��ӽV�L�S����o�=�<���=�v���<���=���D:�<�MG=��I=E�Y������ý7d>�J��<��9=X�^<3}�=����Hd���]���ؽ{n�:[��ݯ�PG=�])=�!>�x��{i������#>k�>�rH�=�s۽�/=y5=(�=��5���=Ϳ.>��%=��>�=�����=�ݥ�[�y=)$��G�=	=d�==�� ������6���3�=�?<��<,��=�����<��q���=�C�=v�>�Փ�>�L<�S�=��:xMn=y������v�˽��!>�=��L��#m�{@7=�O<'�;k�	�_i�;�:nj�=�ϫ=>hm>IÕ��u;>��/= 57=m.�=�J;=��<��x���;�;���z�=���N��=�������X�����;/:$>�50�P�D��3<nq�=���=s�@�]-�=���<!��M�/���	�[eʺ*�=�ɮ�ٹ�IU(=_�
�L&�=u���]�p�#z=�>|���D��^���<5�[<)�>��=��)�cμ�\��g>���=!��=�_=�X�;��=�H>�_9>�����;g��=r�u=`�k��|�:��=pU�<*qa<A*�<��D>��)<iMƽ�6�= ���:�v���"t7<�T=�<<�G$>Bw�H�K�W����d�<���=&|R=u�]>���<��m�f���;g>8��<?��G7���>��<�Ghk<�>��+�=��=N�%<��=��(>Ʒҽ�L�=�"�[��:��<�-��S����E�<�w����={��<q�.=|f���o�<�ߙ��`I<[�?<{�l�m�8=�h�<���`���aM�=H~�}��� 
�>�ӽ�;ֽz#�
T
���E����>B3�=�dK�N/�=T�">�v����G>�����>����C�S=�n���=9��;1=u�ױ$��������=��=6l>H�<�w��E<��+�7>}��2�8=�Z�=���=�H��xz���=c>v>x��q�<�����m�`?�=C�B��F^��{<~#�=�#K��`Q��>
+��e����C>���q =-_�=��*>\�H=߈�5��PC>=��=��;=1���v=�=2������Qܽ?>>
�7�7=�>�=&�=q�>=ɩ��C��=�����O=�(�=gH>�8t��\�=�k����=f~=of�;,kڽ�*��"����;�۽Z;�=O�M��:�y�g����<��l=������5�.=Qb>�=UUc�φ>�r���ý���0�,�9g��"�[>��\�̽�ͽ���=* �c�<ޓ
��|=�"=<&�)���M�#�)>"�< "9��:���l=a���d`<��;WG>��=ٝr��ߜ��"��0�o{Q�j9Ž�a>~C��*<�e�=>#�>>�=<ـӽ�|�>���J���γ�1��)�f="E=\�=�D;=/��Ř�����=�W�=>��=�ٹ=7>�y�C���v��yӑ<�y1=ߦ�=�a�i�4<��=�<�P�=��>38�;��޼�1�8�=8N^=�xj=�}�;6�>��`��R?�	>���=k��A >�l=<��=�;��=�@>愈���=��!<����$���=��V�������{!�=�D��LY�<B(=���<�C{>?l�=~� �3�q���=�l�=��;���)�;*����퍾�|";��U='M���.�8�= `�Y�>�Sʽ���=ۖO�i�<T#6�_j�\|�'=�
�<(C��D�y=o��>2{�=Sֳ<3����>�V/��v=m�7>�:�<�X<�E�����=Qߑ=�U�<�z�=2�>�*>ˣ�V�P<��\>k^�B9?��w,<~T�>i묽��8���J���8�c�Ż�kO���=��>\h��>�=�vv>�_ܽ��־�|�Ô�<>u�T9K>���=�>jyνo�!>j�=
с���7����Ҩ��6�>��<��>I�:>�%���P�T���=�N�<�ýPq�@n;>����D����r�=Xf�=^�=�Re=�;>�>>�\���op�5ξ;�C<cl�=�\>���p�=�2>H*k��z���¾L�=�5����@?e��=��>|+��G>�K�=0�=�rW>혾�E=��l��a��>��H�qp>����+�?=�x����i�F��>ML*>X+=�+��/7��˽.��>�<7/>N�;>�%<搼�:$>��>�V>B(x=
�>1�#>�Z ��� >B�>bwF�:�:<��1<^�=nm��a�=c������=�)��p=o�ؼ	y8>kOf��*�>aV�=�/>��;>�AY>���=ꕆ�q��+������0��l�>^�<f�>��=ӏ�=��e�N��i!C�e�b�	/=�$<R��=L�<��.=���=n�<�� �Y��=A�ν��8>�%S�?��=�􅾱ʋ������r�=9��b�<pT�<�� <6�X>�%=�CV�x����3���߽(j�=u�;x{�<M�<o�>9�<���e�>>v�=���=��n����>��>9/��,��Ps�=r�>�X;�'꽊BY���6=.�Q�Z����Q��vė=A�"��Р<�=�і=����7.l�Uc��c�:>,��=��U��X\��3>�9k��������=[����1K�b�뽿�B�C�=��X��"�=�X>0=�it�ږ�%��<Q��=�H�=g�Ҽ��6>�g0��e>[��6��>j�=-f��a����=V�	�J�>rJ�=[OƽÎ<�)=+2<=1q.�닻IU0�e��=
�ü��0<jz��p֭>'�=��>j�.>A���>��<l=H>�UI��iԽ�#	<�O=5)���4�>�w����F>VBػ�'>'���j/>N�='��������a
>��
>�ټ�����0]=c�:��#�*[\���i=&�>䨾��.���-=�nR��]���:l��X&>�������O���y)>_�[=QL�-"�R�~>� �=9> @�ƹ���צ�*��=�mE�ԙ<�">,��=tr*>t�=6�'>,6�nd8>�)�<�|��͚�=w��⻒=�����J>"�>�񎽡�=�4���o~�B�<z��=<]>h.�=!�=�K>P�>��=8O���!�jM1>c��=��=��W=o�l���աs=�X�=��<a�>t�K<�ҽ�z�*R<����<u=���og�=-��=��>#n�=� =�O=1��=%���9+��J�=�&��u�;���=��>��&�c<N^�={�=ۂ5�]�<�|�<�T�� �>&�=��!���)�N~�<}=a���7ټ��=;����^P�K5=Vn=?�<�����r���4<�[h>�e<"Ew=u�'�'�CHӼI+>�5��2�<��=��>=��C��2q&����oq��A��)+�=*�<��>v�>���=2�����'�!m����x�=0� >(��;,=+
G�:j��3�<TA�=�N��ˢ�\�>�;w=�J�=n�=��=��R=�=�"������ۼ��S>��>�M�=�'A�?�����=��	��;i�^,>1���&׽�	���$>k���㼩�'=��\�7�<Z}����=���<U>,�;�+�=��ʼ��=r�Cv�<$�ǽ�r2={��;?��e�5�2O�=U��9�$>L'>�w<9S�tƏ<���}���_O���rI>�/���\=i+�Nn�=+X=�?g=�1�=4C�=P�<mb�<�ɥ�Uk�=�ۨ=����N��>I�+>�*K%�>��;݂==�=
j��j8���m�=)��=��W�#��<s0�)J������F�<,,����'"�tz>	q�X�F�ҋ?��"@>��=^� ��`0�)9�=�l	�	��\�<{>4����K.����:�La=Y�	>�~�7z#���D=?[�=ݷ�<0x���]=C��=52+=�ş<�Fl��"��"��~�%>a��=�g#������<�>(R�<�!|��8��c���eο=h���qx�=���=s��=�<��b�=�B�=П]�O���ib�F�<v�@�;� >�崽 ��=�E���>�m����=�X�>�:�=��;��1�Dz">;��=�6E<S\\>�==�~�=�d�=�s߼��=���=F�O>Q��q�=?�8���=�Bm=��<-��=�'=7��=�ׅ�c�0=��>�O>C�*>��'>��<�׋=ʪ>�+�=&�=<��x�<ŧ������i=(K>���=_�N�j'�<��e=� ��(=�79��;=@锽>�7>�j>�j>�%�=�w>Cm�=>�N�k�<&9�����G�>l=��]��4>=�~<�>�؄�5ͽ=�W����<�ro��ϔ�	�7�=h�=�aQ:�� >.�=��=�ˡ�!��>:V#�>�U>Y_ý:,�����מ（�<��;�g\��h߽7oN>\����-=��.� �=+��=%��0=�_�>�sW���)>n:���D���=0Q�dýlc>�i��岾�O^<��=�N�=>p�r{>�6	����2:>P���>/(����=���>m�O�콹;W�
��=��1�� G<��=�G�=�=�L'�ц�>���=���=Z���y��x�:�Bf��E]�
U��V�;��=��#>@��=E��<2��==����=�91�w.>׀ν�N>A-�)J���>�ķ�@��<�@>A� =����n��Ho�=���>�,�����=}��:��=�D�J�:�Q\���n=��=a�i=��+>i�>���=�ū=�O4<ʝ��>�t����=
� >�t�=�B���(��W��	���I�輐�ɼ}=I|��L��2>0��=�$i>g꼽.�'>�N�>7�<6��<��={�<}&�W^�<?�^=e�=�8ܼ�H>�]��r�>V���ּ h.�z���G��E3f=5��=�B�Zt8�%
!=q��0�f=�ڱ="�=����w�=n�����ٻ�-�<-������Z<�<�n]=H>X;����<>��`>]��w�=���=��[�d2>v�R�#�=k�N�&��e��;�X����=��T=?�����Z�0>�"���Ẉ.�=��=�1i=q&>M8��_���Jo�=��+<~�>��$�F(c���<���>������8=ҾQ��=���=�3�=90�>��Y<�Y+��lZ>�>=��X�ۄ�=��9�.�;�سG=!�<]忾�4�=m! =��$>lD���ԧ>�푽u�=d!;\���7��W����=�5�=�#�>���">PL&���=]=gn�J%=a�>R-	=�>�`�=7�ĻLd}�K56>I%���<L�<;7>�ƕ=Cc�ح�?�&>t_��H���D>�;���?��:T�2B�H��=�[<7���M��&��ΐ��u�x����<��k=M��!��Kh8��->,Iռ��[>��>��=AxH=���kj=�cV�rN(>��;���=�Q�	:\�Dӽ�>�yѽ:%���@�t���]�$�̾�V�=�!X=̔�eƽ{ya=��>��,����.l�<yɬ=�J��\����O~N���d=3>l��o�c����iN���o�=��n�YQ=)�?��P;>A��>9�$��vĽ�k>M"�f���X&����+>�m�;����6�=n��<�H��9��<�E�=MUI�>���o&=�k�=@�uS=��O���>��;�P����fQ��k��=��ܼ�\e=�ny=����>xm�q������M#������=���=����܉��q����=�����ݼ=M��^��ra<
��;��&>�d=-ϫ=.9��ܴ�<�a	>� >GU�����"VA=��%<��<�>���=B����=7 �=xD���O>IGg<D>��y�NG�G>�Φ=\X:��,������6���UY��+�=�:�����=m���>�4��.<�>F]����=�y�����������}�ӽ�fE��b�=�:���F��Q��<O|����ظe=�����.�eQ�� ��4�=t־4�8<���a�=*<�<�/�=���=*��=�Tp�}:��|l�׃
��"p�`�*�v�ɽ�	��ʛ��>!w�D�ӽ�I�=�K>ER>�ƿ���>-�G����=�6�=�����b�=/�н�n�)=g<� D!��^=z�=.T�=��=/ܻ�y>ʕ�>[�:���(>92��=x=��<	��<��>��<<g�6>��� �=a������=�!&�:��L�ƽ�?�>��=h��;��=�׽��u��#�=��ѽS|a<�^��̒�����/�=%���@��ȼ���=!"���/'�4t��k�>w�	���>�<�o[�Ƕ�=I��>5Y㽛�=Db^�<�y<,�h�Ⱥ���
�
8���ýR�=v��D�x=�{=�  �	�a��u���I��K�5���=�@�<�6�<�ν��,=B�.=y��=^�=��X�Y9����e���>P�H==�>��`�:R�`f >&�>]Q��@@�>U�=�C���_<�c��.>���;��9>ē�=�=���oɒ=zٽ7�=)�:�k�;��o��~���J�bަ���X�KǨ��1��*%��t��<,��󁻼}H��(��Ӡ
���ؽ?%��)�$=\>�<T^�<��,=��l��g=�'a�M���]a��xp=�0��7�={��={���J���I�=���Ὀ��|߼͙ӽY�N����;����ky�m劽R���3�<@ �'n���k/=#�;=��=���[���V�<7���� �������M==졆�P���o�潫����P������F��׼�NԼ^���F'�����y�@D�E�=��=�]�<�(G=B	�=M؛;^��3I=�3=<�@��8J=NP�<���<D��=���=���Gi>Z=?">Ry�<>]T=0=R�0n'>TL>�ި=T�s���7>/�y��G'�3zY<���;�Z>U�!>|���*5��A�>�%��)��1�ޤ�=���=��7����=72\=��L=l�����=�9Ҽ	�����o����ҽ�F�=���<FT��sl�=���Db>C��=ktN>�Y�<��o��μ�O��=��=V,����==�Ժ���`��P�=$ �<���=ݖ�>Q՘�Eiq�J�=��G�ݐ�=�0���F�;��;;���p���
><��!\=,��q�<߇۽� �E^��>*N>�Mo�a�6;��&>��w;����=\��Y�=�U�=�<������=a��%�=F��=-�.f�=y^{�q��<�e�=�Ƭ=)�<1gŽ�N��ha=Ȩ�=߽�"���|�B��;h���">�8�<a�A<4�b=��$>Cpx=.Po��E\=�a�=���<}��<6�|�u<7�.>'��;i�.={2�g�>���=/�:`��+s��h�I���<�%�KvF�nr<���=O�U�-�>������<��_=�]"=�}½.@�='1=�Ž�p�����=��B=2�=������{=]���}k�=������=Ҭ��s��=l��=3��=:d��L�=�~��3D�=	��^��Fz>N�>�2B<�J.�(�S>�\!=�_�=aDC=a".>9J>��="���Uof��U>�0R�*�]�[c���r�=�b�<ɳ���:�^�8<�l�W�=Ei*��27>��� ��=�	��v�<�:���1���\=�J˽�<K���<����/�+=�� �d��=��=څ=��轘�0���X���f=h�=�wX�Q��=�<yIl�6��Y�>8f�=]�#=s� =, Y=R��= 7=J�?=�}=��<490<� �;��=�c�=��:��=I����>6��=n�;� �=�༂2�<.D�=�~������d�<���=�8��'>�W����=�0�=���=ff�<�޺=�����<S�`='��=Dh>� �=|l*>���=g��<0ms=j~����#>t^��Pɠ��Sa=�k=���=��;>*1@>��(<��">k���7=���Qw��L@�����ov<��o;B�D�CiȽ.��=��6��=㞢=-��(�*=n��9@g=�:��2=X��=���=MǢ�q�/<�(p=������M=���=�a���v�[����c��Ed��ֽu\���qѽ�q����˼�[<�@��/��qv��N6���̋<�!��妽6 t=�f=��=i踽6jj=޾"�� �c亽��W=��C=���"r����;J�x����;��?�0๽��f=��j�c6#���TGV<�۳��@}��=�FȽ3�v=	�A=!߰�U�r=�Џ��۰�S������j%�=���)Pl�6����%����#�ֆ;�q���/h�*Vl=���%�=� <�J��^?=F�-=�e���ۤ�{e�������U=Cy��h��ol�>3v��D���᭽"�=4a=��'=�
>�0�2�㽴�2>5"+>�
�s�$����<�[�<�`@����r��=5�=�������	�<mS	>𥤾�)�Pg�=7렽���<neN=J>�Mv>��=`s�=�t(>�,��O�;����u�=�ٽ�O���*<�\��=�y=6��a��=��>��>�/�<��׽��=қ;�.%=�͒��=={���$����=��>��ٽ�n'<Cz�<ts ������ӽ��˽�U�<Nu<�*_���>�j=�ڐ��]=T >���=���<:{�hY���|�����<��%��<�=��/�B�����>��J���i���Y�h����"�=��y=P%=k��=C�����*>�E��b�;O�ٻ� a=f5�=���<I�D>T�ҽ����|�=�RJ�8x�=�i=����|�=�}�<�HZ=���= ��;T^��č���e<z��=��#>�d=i�==�T�(�>���S�>���v[��z�;Y�
��1G>�V@���P>t �=�  >�9��_� =���:>�=�P=����>,ǽ ]�=M?���qн���=��1=.�=@7=���<��<���2���o=$���h�=]�=1�=~N�ϣ�; c�<�r��ݤ�!�<�C�=��������`Pɽ��V��T=�;>#�a	?�o��m�w�̀�NMK�fՎ��LC��ߣ�L��>;��7%�k@�<��O�E����c�9@��f�O���DE�>�P>ڜ��a���%���ǽ3~(�r�>F��6O��VB>AN%���=���=���=u��<U8��J�=_�h��N4�sk��6N=��=���>�0�����x$> �q> #��s>�
#�6�+<����-�>�\B=l8>��=+>�O�v=��(>yQ�<����������'=��>R��:�X�<ՔJ>�;�=�v�w����b>�{�>       d�            {����+�=	F>�{۽9�w�t/�<j[5�J�=������=U+U��-�<І�xK��xXB��<�Oh<�_�=�s�AJ�N��=�i"���`���=�����sPM>������M��l9 =HŽq3_��Ƚ<ǉ�l=~��;���'G<�j�S�
�d~
>(�w�"����n='�[��r����>�Z#�7ؤ�{��=ꂽ`:�>��<~�e��!=�����&��f�����x��%��<8Ν�܃C=Ω�����Y�����:�7=�o��ۣ>�5p�Sջf�Y>�l<y#(�ϲ�"��=ۆ�=6k>x`#>��=��F=�0�=="%o��kg�":7�_�=���<D>&����=^��=�e�<|Y��8�����B�->�,�<�x�=B�x:�_�wі=N��=�.��NM>%�7�p�<���=�0�<��<h";�Ԟٽg��> �=�$M�LK��0��< 	5������.���'>G�"=� 	�η�;��Ǽ��N=5�=o��ג=�Q޼��c=j����Z�>�$�j��y�=w\�=D'��V�:�T0M=��<����=��<VCý,��c������ӽ���>��^�o��� �,)�����<L'�&-���볽�{��ڏ=���=L�F̗=��D�P������<;���AN���˼n�Ľ(�e���"�r�B��=R�Ž4�1=���=e1=$��=�S=]I>�o&;~�ɽ��;�`߽��y=��=�ט�k�˽���=z2� ��=��_<�Z��dh���&> 4u�)ݽ|��^X=�-��=��=T�ܾo3<�[�=~����?)�w��=���q�=�h:=)DB��q˼B�㽏�8=Y X�{(�=�Q���
=)z�U�"�Qi=��4t��^'>�ʲ�p�%=���>�'�<M�=�x,<J�ѽQ&����|�ֻ_5��-�q>��9���l���)�=:��=^�(��aż���7�>Ju)�lx9=#j<�hW�=��������:.N��N��@>�$�<��>����)�M>���=r2�<�w���=O隼@ç=V\|��ǣ�	�=��<?KF� ��=�u��t�<��<��>?X��_���YA�=�>-:&�ҿ�2Y>=X�'��A��]9�=�����=�O���7=�v>�����N>:�>5ξ�U��I��s4�<b��<ڌ�=@��>8�>���K���<���=�X���掼=�D>��
��g=�D�={���d����Y�=6��=�$>�C����h�&� ��>�n������4��}sȼ�K�0L��T�<�bw���>�A�=�����[=wlu=����[�'>�c����e�?�A���'!Ѽ����Z@=P~n=���<r7���=�H>��ꦖ���Z�z�ս��n>���>���=A�5�n=b��cZ�>"�n=}C2���H���<��G�c�^>��=�ᴼ'C̽ ��/��=�<��M�<�B;(���n�c>*l ��I>&Y�a���u��DC<�a��m'��e>���Q�=H���A=�&?>��p=��½2��t�>n|�=N�<=%-i=��~���)� 2��"�O����㨾�w��kT�� �o�]>1SE>�y
��쪾�Lh>�c�<����{=׺�S�=/���R㽋*��
������s�\�A>��>(�?��(F>�3[��=�=���<��=<�="�8�-��d֋<=?>�L�=�Ԁ>�b=��N�����=Y�=�{�=e�R=�M4�����n��.8�=�������gW=��<�����T=Υ���O�=�=�N�M�=�GԽ����~�������i���6�z�=���/���l���=��0=���M�>]���LG�<خ��>�<��H�/��=�Ub��x>��w�0=I��K��:f��ݎ<��yo�Q��� H��#>�ý��C�!��>8��qO�<"�����;V���#tr>u�Ǭ�k2;�R���2E6�p"[���6���Q>ڮ<5� =��@��>,�J�DMM=��=��!<p>$=c��=���<\��=�U����4��8�=�SE>F�G=��L>����J=$_��̣�>8�a<�ã=�ڇ��ʣ��>�t�vh�=���=guڽЛ��K�L�QNy�ǣ�< x��YA2��Z��]E��g߼%<��0�=Z�����~�7���<o�F��F���/�=܂�<c,2>X�+=����;�>y{ɾt=h������+�Ͻ*�d=^�=C�=dΓ<��(<Ҕ���bY>i; �n���s�"Y���z�>OZ�>�C��*��\���ѽ��P=ܒռ^��C�3�	�`��]������X��*>g�=���Հ�>o$�=hţ=p	�=��#���G=�_���=�~>�.ýC�d>�N���Y������i[<@�)='���/-�<��l�=�5>�L��t��7�����=�@ֽ��S>�4����=t2��P~>�-����=P[h�SG��/>�u�&w�:v�a�H.�=�1�k̽�	Z�4�b��ua����zC�
I�>P]@�{ի���p=� �=-�J�#��J��=��>E��>�y=��9��0���8��j���ʓ=wi�����p�^���%�x ���칽,�D����.,��f�����=!�����A|,>���K��_7+>V�o=�H>����"yl�hRE�/�4��7��΁=oS>_	�R
>{�ӽg�=�JB;� ���=ZQ=��>�7�=t�^>�?4��/ڻ(&�n�м�h���(�<T�>�A=��=�(�}#��^��=4������;�=1�f�'��Q�>=�L~>Vס��Յ=&�*<�5�a�*>m��Z·�マ<J�=f�<ULE<�o��^��ʳ=]�K�o#�����<�>���:�ހ��៽jy=ُ4=a�c�b�<7���t�5K��^	�=@����=��=`�n�Owh�c(f<��}=�Ô��+>�Aּ�ܽ��Ž7�^��c�=���<C=K#o�����Bɏ>b%�zt��qD=0߆=	փ=r� ;\�Ƚ�j$�|Ľ�3�=��漚��0j�U�:�%�f>��<�=K>�Y;��:��������VC�{VԾn�N>�j��������G��>��X��Q�]'2>�m;>��=�f=}�@>���p5=L��=�SȽ(�>����z>s22�>)�=�t�=#a��P�����Ŋ�$ƨ��'���o>�D�=
��=��t8�U��5H�0���ν}j���=綗���=FzD>g˾����}脽Y*/>V���8�=[#P��	'>�Ɩ����=Y� �7} >~��={�=NS�=��ҼA�<��>zꕼ�-�= �>�	�>�dͼ������>�>�ћ=�Y����A>�b��'�<�j�5�)���=o^����<B�<���#�=��x�>�X~=��e<�M�I¼���4T���:�<>'�=��=�ڽ�9<gK=cr>=m��yc@�3��� eʽu꽥����� �b�8>��P>�sd=���<N�V=ab&�>�Ƚ��g�RU�@�=���=$�]�>|{�K��>��M�H2���eA>U���<t<�g��G"��r�����=�& ��KY=z��#���O�j��a�>V�>�o������D�F�#>� ���];�`�=tZ��#�=٣>�r�=Of�=�:#���r<_���zWU>o����1�=EN��
>�P=퐯�EC1��D=P�ǽB���o�= ����G�!3�=�D<>/�=�O���;<���'��*1޻N��=�C�<����4=�{�<��=�q��&;b��3'>%am>kf��� �4�׽�o=9UK>N+�������=�c�=�&�==J��H�ݽ�,�=n�Z�%��=j{߽K>ɨi��`=0խ=�Я=2$w��)���O�]⽑�b�@0e=xg>�c�;��>~̻�N�=Z�ýHޱ=�P��`T>/��3\>}�6���<�)�<#X=�\���=�P��Pb��#o齼�s=m65��6���Ö�A�{<�
v�>ԩ���nb=�" �2W<ZVb��l=��_��5ž���>�������I�<>��<�<����t�.h��%���̓E��Q=�ʯ�:牻=QGQ���;��P������
�;,��_=>��K���>�)=v_&<A���)�u�>�#g���4�_6�<8��7D`��t=��=�w�l
[��ڑ=���=�Π�J�k�gx>A�=�*>��>�s-�3�%<��潶H
��];�-o���ڽsŻ�W�����.j���ef=�9W>E<s�`_*=�gP�h?>��v��j���35=�즽m�=�����*��𴽄�����"��^��]<:�Ǔ��F=��۽��|��]��;�< ��<`a3��8�=Y�ֽ�sh��֓=q�6>����ץ#>3��=I�E>�lQ=�|�:|))>ii�=Y�
=~���󃋾�S2�`4��%���n���=QW��ν)M�=:M��9�>��ֽ�;�����N����>-���Yn��
V���f=":>����p�=�:�����;��G �=���<-~>�0C�i�<5뽰=>�K�<�-�=+���	�=�����;=*uV>�xv�����Q������N�t�Hf�Q�S�¶<�!ݼp=���L=��ȼU��=v�s���{>I݁�Z���X�F�B�mu�=ob>���ʥ>ܓ罳�P�S)>�g��G}�#>�:�������*>��)=��=3*�<���<�d�:���=
��=Q@<=�7�s� ���= 筼�ӟ�0���=�;=P�=3tu>��E>�=>��.=�턺>T=�]��en��rd���~<��@���ɽ�����*�P��=m�~=-�2��k�=�i����Ͻ�ƽ�#v������O��<�>$�C�L�D��V>�A�' �=��ǽ��=6��E�Ea�=P���2�c�L�\���%�
Ϙ�1ƽe�8��t���>/m�=�B���m-���M�5m]�NT�����6�ż2��=��>\M=�=CIS����E��P����<�j>�J �����}J¼ՙ[>'�@>hj��y���թ=�H��Z﫽/��ʌ8=>z��	zP���ܼ���=��6��[B>�BW�۲����6��WD�I�=����=m���a��w<P���*��P�W>�TS=��o;�r�=+�F=����mh=��P=�A� ��d]��!>���\�=U����=]����6��'��4ǽ�Y��+>%s����>��I=&#>��#>�n��x >i|�=Mx�>b����>�h�,b�;�R��K��@�R;�Q�s�9�CA<B��t�`=$����(I<�O=�!�=�ƾ����6�a>�2������^�K��>�A
������a}<s��=����L��=��y�Il=-�t=�O���׽CX�;�gd=������;+���;�=�2����j��d���p�;��V�ܭ�:������#&�-�����ƽ��~�Nra�y�Y�Vt=c���e�	�0䝽�nP�v�9��1
��k��,\���<,���3�>�A��jZ�gj��bp��ּɹ�����hy1��>[>�bȼ�F��}
���=;N<�h���:">���=V�<(��ό=EP>DY���2ؽ�5Ľ��0=(%=s��}��>5���μ����Q=ia�GU�;��X�=���@�=��,�]ͫ�!=8=��=����=� H<X��>:y��0cS�m7̽V�I>vr��:��>�Ҏ=�n��H#���޻�P�=��~��@/�=���9n
=ݯݼi:��K�7e�i��D$��?Q�� q)��=�$��KY�)F���s}�ZBV=/ �"�y�@j�=>,��<Ն���4�L{��Pؼ\��=�Ғ<�R���4~����J=�o���=�׼����`�=?�>"�=f1�H��<�D�ų��<k�=����%�=�Z<�̡��9��˒>��4>;P>�>��<��^=LG��COu���p��֥�����
/=��>>��t��fz>��нΘ�l�g�+?(���ｱ.r�.{�=�[���	���^�]m:�X/��� 侨4��f�b�FGr=j
=��<?����;�=�᰼�ʤ��X���\����$��?���Q>O9�;VX�pi�� z���8�<K�:>&好��%�	;����<9k��f�=��&2� ��ֹ=�襽*~�=��=�����=�-�=�t;=<�_����;���5�!��;*������<����G;>sV��;�=����!���}�����F^��8��n>HY=I7>6r�E� >&A>ɢ��:�=� �=��u��S�=�u��H��� ���Kf�d�=��;>F9;�g���>ʶ;>H�=��˽=�<�4�܅>�%.���T>�q���d�ˋ>t�>��4��)�<`e>�ҽ�jk�:
<��4�=K��')f�YY��������=�'{�-^(���=n��=#^���z�p72>�D��!�3>���u� >���I���@>,>#����=҅g�z7��m��|��;?�=��`���S��ݙ��%����n�`�ݼj���Km��7�`�g�T��87=�.�=|��=�����ڼ��q�4�<�QG=N���~���PW�E��+�w=��=���<@�(���=2H>���_8>��J��㉾3P7�V�>�UǽW4L;wƽ@ ����=��u=���=C�.=�Y���8�<?|����=b�;^'���Y.�?��B��="��=��=�3o<v�<@�ӽ"�ǻ3`�=W�ɽ5A��B3��8f�=�\=���=�����B��o��Z�F���-�Xek=NӸ=��+�v q�AS�=��h��S�I�m�dr��`�)�Y �������`�K�'=��нU��!-,��/��J��>��<y���
ܳ<���D�=��>��=i�D=�����=��>������q@=�>pD�29@>���gf����=zK3=���;�	�]��O��\�Y�;=�J�<*y>�6>�r�=9�5>Y��<H5�<�D=�DF�:�=)d��Z'=U5�<b�=�l�	˓=u�ɼ�ص��,�Y�����ﶂ�C^d;�1>r��w,2����=���=Pz������Y�\
�<]ӽ�؉�����[i��H#���\=7���h8���/�=&�޼:1�o/��jv=5� �Q;<Y����:�eW��4>�#˽nE*���2>uz��C���	�=[2�����=��н�Le<Ju,����ٍ��ƈ�<d�@=��d�����ú<׻g��v�=W�>��=�����1x���H>����1��'	>�W=�%>��3�� u��-��'��؀j���]=4�>Cd��r*y�f������n����<sC=�܍=XH+=��]A> �t��h�=Q��=��=����f!9�I��s��?�>^$�=�U��O�;r��<>����B@��Hx�;?�=�r��o�=ޤ�������E�Rͽw-��*5��{�F�y��:6��=�X�;�9�<�~Z�t;�=_��Wj��YA<����i���A=�O�=��=��>�,��U^�<�H���>Ar='8K>��-�ژS��A#��=�f����W�<焕��w>ޭg=�N輦5�<��&����Sd�=>0�E����@!Ľvk>H7>���.�z���\>h灾|Re��^������`
>uiZ�i�e=E�<XPƾ�x�=E��Pq�*~ֽC�=)�4�a���)���G��3����|�{���:^��_#>�@>6z=�= ���L$�=р?��s<0�\=�(?��z=\���>�����`����A�=�[�<vD>b<ż����#0@��5�=�Gx>�A=v�8����9�qR=wJ	�xܽ�q�|=m�4��ޒ���>Ҡ���r��w�QB=;�X9isǽkP���&=~�<[3��.R�>tb�=!�"��/=�{��&���p��=�˽�VG]�/��=o����h��O���������=-*�=�k��)��<��<b'=�o��kȍ>�!���]���9�һ<�Yp=ߪU=��ɻ5)4>/���Cq=�I�=_�=ơ�=3`=S��< $�=�X׽#Mn>n2¼ D"=k�x�_c�=tk�5�=?�(>�U��o�=���ܘ;���%�ͽ�'F>G������=�H�:�n��?m=�9�=��6�4z+>�ǩ>��f�j�u�.�>���h�������~H����U'�<;#Q����<�v�=S>"��=eY�<z��9���=@.�=@���d��>�(�RH��{��<��� gP�b3�=
�>�ˁ��I�>��B�R��=i���T� �l-�>�Y_<Q����-��
�s=1 >X�>J���������R��|�􀭽@<����*����=�~���$�I���s�Y�=�=���=�H��=�I���=�� �vG��0����&����
=hy�����y��>�w>��Y;�����=���=/�Ƚ�H%<W�$>�ま�J��AP�=4��O=�u>s�%=*'�=��f�rr��4�=]���涽���;#>[�]��	��� (���/���<=���a��=3��<� ����O��n/�������i,�<"��<��?��邽vk��7= �4>*�4����=�5��ɢ=�⳽��ѻ�S�>�JJ=�(=>Z�>@�J=��>�R�=ګ�=�F�U9�0���+F�=߲ >��<*���Ľ�o���>�J=;=`�p���x�s����v�b�;� ����=x��=I�F����z����<K+׼?nK=jҗ�*�<yR�5�D��M8�[JG>�2��f�=��=�f���=v�ƽ���	a�����=��=��=�-z>	�;n��٧g>*�g=���=�����<a%=�G=\�U>ע4���>�O*�`��=�!�*�Ҽ���>B�9=��3<��ĽP�=�!3�����F��=UJ��V>���=�S>�����LE�=Q����ý�T��0�=h�;�qt��=(]>w��y�y�Y�)o�x�>Z�νP4k>9>�c��O>
�W=��>�	��P=��_>��A=�ǧ>`Ę=�$����#>ق�d&�����=8A&>� ۽#�U>������T<(��>��ݽѥ,�a��=��X�^�<[���>1�b��ub��¼���߈����6�g�f�<�V>���t��=�	>_�=W�A�&rh����=vW�<�g>;����eо\q0�$W =�Wk>E٢��nؽ��m�m|�O�.���2���>��>��y=h�<���=�@�������+�|��o>[/A=��O�R"�Q�T�3,����<K�><Ž�iɏ>nh>cr=½�<]��>���ꁾAz,>,��I�<����r�	�Խ�Vؽ<�=�9=eČ�S>�.ּ�L��t?���9>�����==�>�b+���(�h�<<)C
>���R�=�,R>.���ʽ��!�gǽ���=���=�h.�O5$=Fcv<t/!>���=	�.>j?5>�/��d=��=^�=ND=��;�&����l\�ZK�=�3�<ĕ�=J�=dX���F=����/e�=8si=��#>�p<j��<�J����B�h�=��4�hV*��'2<15;�h�=�d뽮R�����\,��qO<a�潤(�=ga���`��5�<8U>sY�;��)�\K%���O>� `��8޼y�>¾<�3;OsϽ�Ճ:���?>c-->�����@>����4��u��lg>�B=�0�}�k���g=�ݨ�].J�(Ἰ�Ӽ��]>^<F>Ye��]N�l��=�A⽗Ž�^Ϗ=�Ys=��=O�½ ������>�k_��u<�6�;-��1⪽�)�=���<��m�9K꽼�=� H��I�=AH�=Z����=��C�R��n��?� �l��;D_���̚;5I=tm>��>/�=3oZ���˼�	߽�#�=�:�8g<͒�=��5>�O���r>�轜�^=�gt=`=n=1(3=%���0>���=DJ���=ij�=��ڽMC�r��;��C=A̚��So�~�=���=�ºht�=@s�����;$�:=6�K>�$I>Q9Ž{�c<�L���T>2	 �kY�<W��{>3W=ʺӾ:����{�k��=v�=~<�����=xX��k�%=s3�>��:�Wm�x2|>ʭD���=M��<l?�=g��֟�>��3��8>ɢ1>������<�f=�I�<��=:�> ��<�lC=ړd�g!^>Cg�<������8>An>��5�QWὣ��<tE�=�C�F#�=��'�|!>�?þ{gN�e7J>��C����=ݐ���'���=��U����^�F���8���J0<��'�`]���t�=@�='0�=w��<����R<�h�bA<>R�;XaP�f���v���<Y�r=�4>)Q>>9�=-�=D��=؞�%�>�>��9<�� ��Q1��༎b�=�������E�U�ϐO�އ/����=7�:T��=�4�f�"��6Ž)�(>�A���>��rw׼|�=�p�ѽ�����<��>�1�?/x�/�<�s�=8�߻l"Y���W�������W>q7<=�-��FB=I��<N�;Í�=;�l=�=����"K���|<�ie�C��=����.�<���Tp�?弞+��$_��t=������=����	>�UʽG�(=�f���k�gp�=���=�ޖ=����-Ǽ�x�>ox>>B#>��r�#����>}�>��5�-�\�m�`��*[\�#�нR!ƽr�3�6�>���;�ޱ�=����Z�O>�xJ����=��'�B�h>>���L�z=��&>Q�=�
��p<(R}�Q(��_%���< ��<w�:ꕽ��ü��~�2��=ӥ\�ڮ%��%=��<Jn=\	G������0=��B����)��a��w>�(k>?���bK=K�$;+=&�>>𧋾����po�'С=�����=�W>RN>=YX�����=^VB�:3���� > ��/л>0�x>��;��"���[��a�齧͖��ڿ�$��t�=5@w�W"��=vE�N4#>��=����q���"�iR �_]==��z>0M��ό���>Â=dY����6��*�<��?>�*Ľ�д�R.�;��KLܼ,��.ŧ<������=�-ܽ	�'>�=5���t�����,�B	�|�U�V�
>�
���޽�閽7a��>T�=��=�7�<�0T=�5&>��E�~L��J��b\>��$/t��>=>'�`��<K�	>Ueu��8��<%�ڮ��2P�=��n����pQ��0���Z�M �����t�'>'�2>j"�;o�D=�o�=�|�=����@�����w��[�=K/��=c]4��нy	�=
є=3�Q�\XD=���;X�S=�<��Z>�J�	Dp=I\����H>t/�>���ѽ��q�=�v���&�C�>��g�������&�b7Q��
%�����K=�jC��	=��x>�I>zr8>��>�	>>�b=���;�=�����ɽ�+�>��;>�wX>Ƹ�=wZ켑8n�C�(��m�=�e�<���=�r׼��	��a=��ͻ�X��\�T�L���=� ���>mb�\�>���;?�>�d�@�F�=!B�= p;<�=�s�=��=� 6��S��-�Ż��=��;�$<_�ͽ�r���c���=~4>�#=ETh��>�N�>�d���Z@>2�m<+���ף>3G�=i�����>�>%=¿ݽ���=d	$�H	>eB��N�B>%��(�����=�T>����t����<>�o�x���Ҋ=4bܽ�s���<@�=_�|��T�<��O>�����T^��,6=�E8>=$=I�;m15�_X���������m}���u={�K=�;K>n��=|r*�ʦ�=�� =?�5�1�n>%c&=��b>����Wԙ�T�����k=Ğ=m̈��P�>�?\�l�k�,>�L绡��=҃齀��=;]�=gc<�JýA�:����
��<Zm��aq�PMɼm����u�1�/G��Eֽ�z>h�_>�3ʽ*�w>�bF� ��n�=�F���>J<�|��<1���C�&���<(���=�G�=Q�<���f=��н�Zi<�7��)������[ �:-Ҍ���%� �>$�`��#=6�3=>���i1������=|P�=�r�;����*���.������]�p�r=�zm=)ZO>�D�=[����S=��d��2�Ĵe=+�;�����g$�2����=������{<�Ȓ=9��+s>��9>���=r_=�P��4a=@��= ��qY�<\��&\ڽp�>��X�=�W��H���=�f*�8�=]>�5��$Ž��=�+�<��#��EC>D6��@�=*!�=�b[>���F/<9�����}�=׀����G�[��<��8�ܸ ;b��=�fe�������޽��9��P�+~����影�;�����ȋi:��=K��=ܕF>����)�\��=%��UP��>��*=��|>8&�<܏A�"�F>�o�>�sȼf3�=@�����F>���e�[��1��l�>W-�=̥��u�<��=?*"��a���<���<��)�̅�	�:|+�� ����2�	G������ �8�3u?>h(:�)���8>�Gm(>O�=����!�|;��-��Y��M�=-I\��{���c��9Q��-[��aƏ��=I�`YG�gVN:�q��|��;>��½O�<=��^�/Y9�q >�,�;�T	>���=`�ؽjN=1(�=���:�l�9��z�ʽ՟����ڼ�߼�[6��] =v�����;����j>>�>R�xs�=��=�/o�J����}ͽ�5>�����B�<�M��3�/����,�R�z=�������=ޟ3�`�#�4ű���=2=�<a��<g�j�|��=��f�>�������B�z��P��>�/����0�?>wG>�ҟ��c ���=W���Y�=��>=ғ	>�(�<�%{=)��=�p�<h��;vc=5�k=Q�>G0��10н鋩=<��=w,=]Q=�)j>Ђ2�L�<B<���>��;��G?=|�p���%>ts=���\Y=6�b>�I �z(�Z���S�&��o�D靾�
�=V��<��U�k� Q=͵L>$ʼN5�����=��ڽ�ýl����3=$� =/���LӽK��=t!н�ൽ�X�=����=����b�5i�dR�� 诽��������+�=�r�=��;�S���W�`�*�<��=>�A�<���A>�|�<"���N2>0?�u-f=�`>~�="(y<����6���5>�I�W�=E��g>�G�6�澀�>���k��6��II>��ӽ쏽hA�������%>��w=�����=^�=`w�<����(ּ������.>��_�g�>�(\����=5��=�-->E�н&F�9��/>
�~���4>8�W>��G=�e'��4>��&�,�,>����d�=�ܽ/z�=�����b>�����<����^=X��=vk��J���&��=Z�l��3�="0U��ϽFc �ǈ���Y=�𙉾��5�zR"��E>,�]>��5������T�J���,��x�=�����g�S=�I����/��<*����>�{�<�:|=�i��Ȁ���n=���gjg�V��=�>	�> �H>�io�U�@;G[>�v=;�9� Ď��r�<�,X=G`�����=�%��D�T;�\��1�/�����B=B�T,����=�p���5�=Re=���=�,=��=v;_��MA=��	�4V��ۼ<��'>�\�Ү��42�=	��ĝ�m�=XT�����=y���^>�Y�=�_#=�c>�8���Mp�.������&z�
v=��vQ��� ��� �=¢ս��?j�W�� F�!��=��������+�Z�<���R��}��F�_�`>�P�=£�ҾP=@!�R=��K���%�^�4�E
�N]�=��V��W>�B\�徾<�B�<�-ҽ5 ���~>��9�G���i���gD�=/�=�rξ����4����H��l��L��=Z�=~��=�N�<�撾 ]��n >PI������6wQ=>�A��ż�{�9V�<Q$��R��<�3a��m�����;�\��lg< �<7�=<	����O�^"T<       A�?oh:?��?]Y?��?�N�?g�}?�k�?�p?�L�?t�?�(�?��}?Ͱs?���?�Wd?P�?֞�?ؤm?A�b?       xM�=?�>��?�C�>�c�>�?���>y�?�Uz?7�?��>�9A?��>y�r>+�]>xd�>;��>cx�>vlz>�>       d�             d�             �6�l��#�>vI��[��>�Re��<���I̿�ٿ��>Վ5>[���H#f���>]�:��)�<E?]�����      �6�<Y.���� �@��=�,e<�����|�I1�/Ȳ=ܙ��Up;t�=����� ��q;�M�r�(bн,��=�c�|�=N����%&�i���JĂ=�q�z^k=:�6���ս) �=K��<�W�=�L=��I��7O�x<��?w�����6�=��Ѷ|�cM�=�Ft���=;��%�B�pH��;{=���=���=L/#���-:��L=*�C�dE�<�d��>���G��<�(���@\=W�Q=U�=p�)�]_���ݽb;��0L=��A�ޢ�=�ͼc�7�-�=[F >�@��sM������F#����g��r���T>b˼�*��٪#��缰���\����νS�=�}q=�8=���
�y�4��� ������*�C>�>-X�>#>�A�c��<S�l�F�=e#=��>�¾�$5��) <� H�ܚ=�Ҽ *�W�$���@>;�����^���?��=lA���n~��>�����=F(�=ؚ�U[��' �v��=�����vR>�>����Oc�=�(�*C=�콢K�=(.,��׬=�=0�=�I���<=��>��V�=��E���G�U�h=%V<2o�=�=����*ԙ���7u'�Q+�=��<��2���><b@�&\O��:,>'O>;2����>����0U�G`�=������ܳ�=r5	�|�0�I���`#����=��>�6����j��b�=o$��]�Z>���=�����>ܥ�=& ����>K�>PF��+g>��V��ѫ>U͚��M'>2��/�U�X�>���=&�C��佌�<GU��F> /�=և!=��ڦ��=�	p�ND��q���=�i�?��}�$���4\������2��]�<�׽73>Ky>t~�~��=\;�>�E#��Y���0�$�K����Re���ޣ=��>LDe��=>�+=�KG;���=�_>32�<+9������T�=�g
�_9E=�H��L�W����.��>7ı=!��=V�q�uO>��̼6n��=�z��X�>�q����&�=�G>H��vB�=E�н���=62�=�ת:gJ�aއ�R �=�[>�H=�6�����=L5=�=�c+>��=Y�+>�齸$=��B����n�W>'e&��l'�w�/�|g�1=��g�"�$�~��M��;Ԓ�B(�=�9�>˙�=��߼���=�w��F�=x4�=]���A�~���Ǽ���l"F>���^!�//�aݾ�K`�#)g>S�>p�Y�\Uͽeő=�N7>󃼊�A�N�=� �.>P㢽�>'�'=2Ո=ԩ����G=�WO>�<E>o�k;p�����(<�� �T��=�����;�����E�<0�=�>��>J�,=j�d���߽m��=��_<5�>�A�<�Ӹ=�@�<�U�<u��;�&;��55=�؇��N��7��=f��<����F�J���޼��+����Ż=ZU��`����I�<�5���5�>�G>8��=l,����=;}�=��0=x(�=sO�>��=����LD=����$����=�e�g�&�D�f=��>�:?X���ه��V>�<=Ʃ��*>��x��}>��;��ޖ>��?��M���{��U?=4>�PE�#��w�彫�C>v��<S{��@
��2�Ɗ̽v(R= ׬:�B0�G�C��,�=;�����>>�2�<�L���;>现=�g�W	�0�-��D=�#;��<Sq�;(���;�k,=��=DH��N�'>R�>�o�=d�V���<�����G�����Ǻ2�hT��;u=���=T��=8��=�|(=,�(>5�>o��=A�+<G� �c�=s�[=8j����=@���<�H=���=���=(o����>;_<4��Pa���ü��]��[�t��<�����ּ��Q>��<A\���6�����ar߼��@>�L����9>�&1�A�R>�
�>�,>��.�ݒ���ܤ>�h�=���=&!���ϽH$�P��= ��!=�'ڼ��z>����.��(s���W���z��j��=�95��%��jQ�=�Wże����e���������=�]��B�	<8,<���<t��<�! ������=J���<�<��v�bE�=�])>ץX�`Fc=F���Q��������=��7�F�������޽_9�.q~=Whx>��=)m�<� ��,f������Q��Ԥ˾���=�<<a�E�	J>q>�郮=(�˽6^�߂��A"'>� �=]K������	���O��$F�Y܄�_!�>5rּj�¾<�T���y�g}�p��f�ʽ�+�7Q��:��=w�+�x*�=��=�'�����Y�5=�t">� 1>�8�q�c=�r�<��>ɔb�7K��v�����R�=/+q�m(>~���G�%���¼�?���׽���p�W�w�=�8~u�a���z�=��=��9=S���;�3��d:��`�=�K'��Ъ��m>�.�=��׽�#�=���=�1�5�R�t���^:���;�f�S>s*�j<2�Z��=�~P�`|��dSm��v
<W<��==���<~�<�;>NWb�f�~��Ud�4� <s�{y��ý�f%�-��Cͧ<�{=���N����|����3�(�ν��<A�S=~-�<)㝽=�=�Q�����<gw��	�:��^�0�Y�뾾��=�\F����=��0;'�Ǽ"D�=J����7L>�R��$�<_��A�4>�u�=��>GJ��-��S�=g��=�/C��������=���R򶾒�=]��<��̽��xE����=���=3��=u��;�����F>q�1=�j�,����:=���<f��=Q[���>��n�Ѻe��X/k��.�<�J":�)>��<蔹=P�ԗ����=�D�v�9=�ϑ=�s=�Ӱ���=�o0>m�^>I<% �~���g=%��=��˾��=�A=�ߑ� V$<ʷ[=0��<{i;4��V8J>,��()��.h?*=��<GǺ��s=1�z=cs�=_����&޼8X�=��9���P>���������
��ᖽ���<������	=m^=`��=x����PG=,>�ZU>>��u-�2��=��=-T��r�=1'���]==����C� �=�"8=���V�<O=t=;>��v>0L)����=�߭�t��R&��K��S���j�4>%�=��ϽA᜾����|I<��_�o;>��������r	��*��=��=ϭ_�n'�=�(���>��[�kW=T��6�=�dH�5�ý}���O�:�`��KM�>2�O<�Q�=r��<�7>:�X=���=�4�쀣�x">t4���Z�=��;���_�=�TF>~��=Ƌ߼HS1=�@�>�X��r�N>u
H?�#���=m�4�����콺"4<�P>�	>���C7��m�*�23>r��=^0�j�=�Ƽ̋нN�<G�=�Yֽ��=���c�=���jJ�g0�M�=��>�G=٠b>rq7���=x[�=w�>33��� >@I���i&�)";>��\�K��.Ko��}>	Qb��Y=����<�����S߾fOػB�I���n�}W�=�;��p�������%>�_>< �9lY���$��>>��O���1>x�}�:�Y�}�>��=0�>��½V�ֽ�L���ν=��.>�nֽ��s�K��=�P�4�g�Qlһ��>Ԁ>
h^�DH�=��)<�����0���=���> ؏�_G>�	���>#=��s=�D> �< a�<-K���/���ND>I#�=yPL=o����(c=��<;�H�qW�:�	���Mվ�	>��<�<��`Ϊ�:$�=��<(f��r��E�����Ƽemb>��;L5V�g�.<��=��=�%���Ӛ������Ž��>���=Z�=`�$�^|���I���?���'=X�;Zwc�'	ｱC�=ذK���=�?��Z��=z�ͽ匘��	��QD=(3=�5ս�Mм9�K>���3�T��{5=q�F���;8=�R?��@w<�Z��G���	򇾒JQ;��@�qp���=
��=/B�<��=�4=]-G���&>5ʽWx��Q�=�^ӾFR�>���>O�?c�0�"[=`+>u�7=��ǻj:�>� ����=-gԼ�a9�\t��_ݚ�����<=lJy���3��ռ�*5��#="j�=ܯ�=��Z ����= K�<&�Ǽ�֐=9��-���[���cio�h�*>�T�=��<��B̽�H�������B��������;~$8�p=q=UAٺ�7�<WO"<f�="Q
��A >y&p����^r>����ҋ�9�=Ύ� ↽q�>o=��~ż�M��o8��T���>˱�<І>�>Rý.�)>�=�:�*ݽp����
�<Ie��ρ=�~��F��>��k<�ɔ=N�;cB�<��<�Qe� �u�4={='�E�zH>�㽱��;�+E>_?Q����
;��'3�o��Ӱ�;$ֽ/;�>r�=�*нz�L�nBɾӡ�²�=�m��>�����<b���C��:3�VO������9��L���j=�k���7O>�K>"�n����ȁ:�����k�����;�=��׽;�F�ixԽ���H�L�G>->Zz�=�~�����N�繨{.;� 1<��2=���<�ҽ��=�z��6ގ��|,�-�'�`˽U���������R��=�DA>��)����"��=��<Wg��C�=�W)�9��)�l>E!�z$��1 =��¾6��9O=ȘA>�9̽�@Ƚ<㬽�A>���= �7���=8���m�<D�K��A]�8��=4�½�nh� �v��,ھ&]��>ݓ=о ��r>i��;��
�����c�+>?=Ke�=F����a>�B)�P1�פc�gբ����}�������y� �l=��4�������5>��J;L��=t��=�ѽ�Y�=���=�<��}�&��4}!���g@�T����N�<eGN��ｧ��� �l��!$�Zr>�e����]�ng�=�����z�����Ke>���p;u�g�>��x;\�%�����v�>	�&�iM�=f}����ԙ���f={#��>ڼ�T`�;`>��<;����u�V<��Խ�����e�!.>{�>�N=ɽGs�=��X>�}�M3&=$׽ ��$� �	S�=��i�&T>��e<ȇ�=�A�K�X���Ț=+�7>�$�<Up=�i=�H���4⽄v������+>s�OW�<CD(��ٌ=1�D�M�=F"<�ӽ���:�<�����/>O�0=ͭ�<�}��$����
>�N{�\��=���Ԟ<�X>_[>Ym�xv9��Rܾ8���澽�M����5��h=eEӽB�=y�⽱�L��~�<{NἩ`K=xK����)�=�!}��v��w)�Qv�=�P:������>)�&=�%���Ƚ�p8�$�x���3�h{)���q>����1�2���K�=#>X�=�%r��=�eL�%�>1�9����5�Y2&<0�����=� l>��
=Fι��x���<�H�=�h���1�Y-���m=����]���<��;�f�=�;�B�*�m�>�J>�Ո�s�<!�/=���[�:��̼�a�L�h�uk���<j>@��	��<T�=��c���b��`輸�>�W:�x��dz==C���;�=$.�<��R=X�K�c6�Q�.��Q}��{�=C�=G}>PTu���x�:uڽgc9�>Y>u�н6V'�}+e�����E�<>M�=��@��榾� J�����)��tXb>��þ@Y�Ӕ>+����z�>�/9�"^�>J��=��|��i	��5��_���y���f��-®>���B����R	�o>��/ �=NN=����5���ʾ���S��V�<�d+>ź�=� �;9���|O�=�T�==<�j��<w17��E8��=�@>��`8��>�\=(�=G��,!��gýZU=;�)<�|�M�޽ħ�=
4޽�(��.�=��p>`Y2>\���(Ѽj�L�P��"p׽�>'u=����(��J>ȴ�S�&>ȨM��|��#O>��=�v�=��;<�>y�S�#=̽��Ӻ�[�3L���t�=��i��s����u����k�/>p���$>h'�<7��=X�\�n���#��)����g�cŮ�;!;�g�+�{0(�v=m��l�XB>1亼j�;MlJ�������=�/>���=0ڸ=:ו�q�F�����<��Y=�=�=�w
�Џ��"R��\]��`���ӽ%�������mD�=&��=$�ּ*-���7�<�=U=�=b^��z0=�������=�����v����'�Sv	=��< >)=P��Mֽ�3�����.�3>��=��=��	>�ݽ�P�=:P���D�=�!�h��z�ü��>=�Ƽ��Pj1=�����;�=�1�=���>�YȽ�{����>@�<0��ũ��>���޾!�N��2�=��=H�-��q��E�=�K��$)νf$>����v�CM�=�k⾁ľ=t��>��F�s8�;a��>�4���>�E�=X�=ocr��H�=������@��k�=;�=�~�<���=Գ����!��y=K��>���h�l=�@�[��=�E��P��^��?n < =4=,�=/C>��8;�Ŏ� �M����<V �HJ�=[=w=7t5=�S�=��=Ԩ�<�8;T��\Ť=�`��=�fޤ:`|�=�Wϼ��r��H��?C��7�=���~�=UA=w؃��2��M�%���s��z�����R�]~�=x>��ݽ��=����V����=5{r<�p=�������<��>�}F���'<�$�<��E>�(˼9�Z����!<<b7>��=��\>���=u���%��J�=�g'��پ�7X�v��=(�^��6���,>�Ͻq�:>_]ý�pZ��mL>�V���+�z�=>�=���S%��PY�dV=2�>Tx�;Y��$h"�H�)�~�3>� �=�:���M�_k<��>F����>���=���<�O���0�=jwh�%�>�c�(�۹���)���&�I�U��Ţ�qΌ>��'����=�T�<��`��=�S]>��W<^�>.d=�O�=��.�8����ҽ�ʘ=� D�ý/>>Ը�؆��E�>�$1<:e��M=5H>�{=�t��!ȟ�}-{��4���9�FZ >�><��=�G�=mu�>\l�=ద>y��>��=V�F���`�9��=�]-��!>k ɽҡ�Xt�>P�,<\�-3>
\�=�f(=��)>~]���D=��ͽ�W�<!�k>�o9�H{
>�t2�)����:�s�=�����C�TU>3C�����]=�ZA��g�fO�=wK�=(JĽ��o�=iQ=����}K�~��==9�=���=)�i>�gľ��r��>�������< 1=�ݺ�N���I����R�Z�/>t 4>�jҽ�둽��}�������|�lh�.�<�wZ�ʸ;�<>)�Q�q�>�gսXM�=MUA>�8V<�I1��_X=�<ý�t>�(�p�t�L��=��E�㊽���=�Ά������,����."<]�X����=��=�`Y>��R=��^����>���F7>��?�p�=r6g=瓽b�.��=}`��ދH�],�J��=BJ&���)x=�;b�P�U�
2������N=���T��<L����g��BO�q�d=j�����ý3}��I4��^����_�=</��
`c��G~�f�n���9-(>NU*���s���ٽ����i���(���V�T�<[��
����=��0�=^��;�h}=��=F�ƽ=��=�0q���>ٓ������ǽ?���󌘽���>vp�=�#=" ��{��=[�=�T��4_<=�ʼ�S��mxg=ߕ����d�+2���N�<��?��<���9�®>�7�;�5$��I�<�� ����=�Y�<8��9���M��>{��=�Ž51<Ʀo����=	a�=����_��l�@���=cwV��W��u���;�k��gk=x��4Ѽn�1>��P>p=���=4�;�K�%;iM<���I>Lo�=:L�h�=�{+�W���`��0$����k�=Ze�<	Q�=%S=�f���<�[�����]e�[�>����0�=�
�<F/T=�Ҋ��ʑ�)��� J�XU�ч�=a�ɽE���5�u�P���^Y��s1�=���=��U���)>���=��=��F�>0W��`ߎ����=PS���ݏ=>0�<''�<�Ƅ������=�.����/>� �=
G¾@�>�lk=�l�>�D�=?���\�=�k��N��=�T��U�=�韼�p�<U�ü���k��nɻ��|>�7>�i5�-\ļ��<��5�O���6w�<��=WZ\=�=��:��?˽#Rƽ/ԯ;G�=D�3=�2ܽf?ļ��F���<3/=�B�5�=�4�=�>=F�J<[�>�|�����0Y��'���9�<��V��=n�˼6!þ1|Z�Q,����W��V%�"��;�b<1�l�P�ֽب>��)�C׽�~>������%ԍ���*>I���½�&��g���Y�	0����<���>Y�3>���Ź�<tb��W�ϽR#^��?��ʊ\>�=��>� �>�#;zf1�۶J>a>�/���㧽�XF���>I~��9>����� ���<��!��t;2��<��߼u�q��6�=@}���a�"� �,Mǽu:>Q�<T�&�� �=�gX>��U��<��ƌ��{�Y�H�p*���X�=�wJ����=G&��Ѝ��D/�==䪼�����f;VO/�/�L>B��Ň-�`�4=l��=(Gf����;^����P��^�ۗ�=����v=�Oڽ�f=��<Uw.>�e���B���M�{� >=WK�/��ʱ�ⲵ�0�=:
���5
�1�d>%p�;�Y>�}ڽsz�=�&=�M�=ծ�<������<�l���2=��9�.��'���=�~��[)W��%�>c�Y�<�<�s���۽�)=rS;�#�=��<Q`��������S�Q��=�����;��s���ؾӣ��X������=�L�o"=��#�;�=�_;����*�=\���,������n��=��U��p��B>ث1=��<mT��L�=�_ ��f���(>�]�;�tǽ[��=mŨ��R��:���1�*�i�Y�->����(�U��4>Cy~=9b�D��=�6���?u;F�н8ǀ�	d3>TP�=���0�=ZO���GB��A���K�=6��=�>�~���4H=6�@����=�\b��� ��#2>H,�;X�=V��=o$=~؃��L�_>	�>oc�<��==
�	��1,�O��τX=��0>|��Q�d�œ�6���|�=�nz�m��{Gk>�n��W��=d��N,��#"Q>��}�6�`�a�=�z@;�+���S�s�(�r;]=�{�����Z�����f�k=��(�m���|�R>�> �M�� C�e�c�A!�� �+��ƨ���E>� �V|���$���s�*�ܽ֐�=%ѝ;|&���G�������=���>�mp�(o��[z=h��6�0�/�O=�D���1%�1ѣ=f#W�(T�8�6�<H���1�5�=�X='�"��o��#��'�;={�=���A>x�"�/)�����ٺ���\j=�'Q=�;����VA��(=��=�=�e��?4�=6��@� �`�6�<;�&��v=F�
�Q~�=�x<��p��
���޼�˙=�V%��2�>�>����X=��S��!)<0$O�N]q�����'^���=���=2���.˼��=�y�=国�9k=��N����=P���Z�:M���M��>5z�=��!?�=Nǟ=Ԓ=�b��̀u�װ�����=�,L�(T��ݍN��_��%�:�[D>4*����S�D�H����0��2x=P*��� =���z�p=��=��=�m�<ޝ=>����0>>�">��=5��<������=���=@�ý�l|��[���}�=�!0�-	�=
I>c��ㆾ�,>BF�>Kh��M �>�&=Z���JH��ve麈i���=)>a|̾*�<�f�>sJ�O->��k�������"=X��;��A���4��ps=t2��B=f�+����A�<������=0�=��< @=��,�7�n<- =M�a�ͻ�y��<>��u8>��n=�4�=ᕽ�:$�<&�<�7��������Y����=q�o�;	=`6��8�=��&��G7=�7�=?�v�@�1���轥��=Í�=�F<�}]<
�����;��l>e$W�f���9=��>�!�����"��(�;	�&>ԡ�q"�<r,��V���4-�v�|=�D��L�=20�����g�X����<�j���d>�j��S��=篂�Y��� �X�0>���=�d�<�'�>xoD�2�3>O�W>����r�>�|>�\���"==CeN=̌b���a<C���e�=�t��D��dX���D���.=�Fz����pV<���=Ɔ����=U`�=G$�(� �}]$;>w����ʽґ�=H{��R"k=�N�_,�=���<���=A�$���4=�쀾��=�Aa=��'Y����!?=A�&=������<n����	���f����=K�g����`����>?"�=V0���<�ǽ�<¼@8 >t�����l<��$�f=K]������3��>T��-����<���>���=�ξ�	Խ��&>=E=.G^���ߟ�=]-u��A��K�>�@@�ϝ}�"'(>�?~=s�<(+d�@`>�R&;'r-�@�{=�(����n24��Y�<;}8�����~>Y$�X�r=#�q�q�O<�a,=Y����Y;��O½�$����:k�{�qf�eT��@���5�?��N��VE;އ��1V�%��;�,<�Vk����c���<�l��6��=�
���0��=O�ۼ"�o���d�$�h�ق�<� ���=! =䳭=��#>254>���=���!�g=lQ�_�/>�uw>ķ=��=�\T>gX�>�@�׃:{��(Ρ<@�����=�ǜ��ah=��	���=�`�=_�R��^ν�t=�����[.<k��=�_>��w�<Й,��`��ݩ�Q��5�e=��T=\�5<Vw�=�/Ҽ�H�oՒ�}}=���= �#=}�M���^>��Y�������!�峼1	�=�U� �n=��>\�ļ��'<N ��gdP��F>�)�<roN=[>pgѼů���罄#���>;�����m؍;�n۽?&5=Wu�,>�<����zN)����>V~]�� �(���qL�W�>�1�=M�v=�<�=��= �$=ļX�α>�_
���=%��Y��<�l=���F�����E��\�����rwd��$�=��=��>��)>����H�=��=ܵn<�B��L8=�3��24���2�#{6���,��F>�7�����>G�<�ا���>��>�>�$O��κ=�{�<C�=O4���԰���D>07>��'��"�>@`��`=Bj/�ô����Y<�;m=f,q��P�.�����=%"%=S~�� n����>����y'Ǽ����D�����J=�ֽ�9�q�4=��,>Ӣ|�H�M=������>�&,��ڔ<�FT�������>�_%�X�ս*Vs��\�Y5�Jd����=�>�%��̻���X�Y�#8>��K>�h@��i���>��>��x�AF�>
�̽<eb�|Iݽ�_���c�>=Ɛ=�(ֻ*�⽬ ?�}�=-7�<�O'���<\�^�.>��>Yݣ��/���5ɾ�=������s��=�u��潵i>d���I���E>��=���>AAN=�
�	�5={��>_�L=�y<�Y� n���&>��	�zt�=󔍼�9�ԫ=m��=����6a�e?�=�A�R��|^=�A��sI��=&)=�O��ŋżǩ�<ufӽ7�y���=1�ýv�y=-�;�?�Ƚ��6=�-�O�x=iZ�=� �=�{>@ߋ=`�������=R�㽈Hj�
�	�ŋc����G
������v�#;=�dP������ܽe}�=��V>,�;�߉���G>pA �1P˾��>Z��<��>x[<B�%�+m�>���<'���y��3���芼򶭼}! >�=#Σ=;��͇��i@��_�+��{��>��B� �>ѩ�>�9���$�=�Ǐ=��H>ђ>Q�> "ƽ|:a��\?�& =Mя=4j�=۔>�;z��>nЃ<-���nн�za�ک�����L=>'�� ����<=.�g���о��=�$E�����f>��0>̃��۽�
-��q��ϭ=�(=�MA�e��=lf���<��A�}��?1~�v'=���<�>؂ �'%��n�����D<+j���>�� ���zt~����=%7Q>"�c������ ��W=3�@�)��|=.������1s�����=�b�<v��N�K=�=��4�=����^Ľf��ѝ<�1�>��=?M��|~Z=p���ԭH��x_=��@�8:�=�M�=���߇&>��=87>,N�=%,���w>�����p6=��$?���=k	=��>�i���=��(� |7�o�(>M�k�{��'z�=����e=��ѽ=~&�7��=��G�]u���;�޽�� =^�f��<�����=rM��b�=��?�d`-�Ao�#��=>A��ںF��[�Ю=0��<HPi=K�@��Ƹ=@i��Nh�elk���"���w��l���z��i9� @�r��<������]<uz&����<@5.=�i����U=��H��,�>�E�q�>�~w=k(=�3���?=��=6�ֽl��=��>�?H�=1��>���_ю�������'��n��>T>"r���m��L%T�����>f=U����ՙ��G=�)�>n=��=�:�=��=��|=�K>$C���>(��<�#T��������<�Q�;s=C<9O>8\�m���ᯩ<x�6�-㡽�^I��i��S����`hN=����ψ�O>'��N��]���޽b,�=���=*#�w�=�HqԾ�Ɇ=X���=���=2��=��=f,�<�@��s����ON����솾�� ����=���ڽ��+��[2�:����N>�����������G>z���;>��=(h�=��>��ʽ�>oI�=� ȼ}ɼD⣾&~<�u5>�W,��6>h/�=��=8�>�I-�ω4>}P��ƽ�|�;�ƍ=zl�_l�=���ö��q�>���� ��i�N�Y�#&#���v=�KC���E>����q.��u&>���OWC=Fܦ=<��(�>IRƽ�p���j�j ��t����	�30O�\1j����Ĝ �+�ļ�wx��=�=� �=ϡ�w��C������BB���x���&�\��5b�P���&*>��2w{>�֨=�G>�fӽ��B��>.J�=�@E�0����<��=_�˽մ��y{�y�<]押y7<���X>=Q^���U�=���>��<F�;�>��L�=CD>op+��PD�I.Q>�����}�r�=Jn>za������/��X�%>�p�=p=�s�>�q���c�\�p>�k��G@������(=d��=!$>Bz=3R��m��=ppӼVZ��e�����`�+eI��М������,�<բ<�O=�ۨ���=�}�=��>�A�<�J��!�;+��=Gs=ʾg<�;u>�<=��>�l��#��=����M���Ur�ٿZ=2k��ɽ�΂�^{>�#Q=BpԼ�$>:�X=:��=�����׾Y���$�<�{�=N<��r����i=dX��&�/{�6���ʽM���*�d���m;����ws=+���k����1<�>���&P=]�2��z�l����ME�"S�S��=]L��N)>I"�=ic�<��ν�-\��CX��Z'�f�<��^>�@�=UΣ�qWA�nj����f���>�%=���>��>!���[�ޝ�;/�=BqD=@=��8+�@�?�����8ۧ<�
�(R>�dw=�-�\�n:��\�������}�<�ﲽk�"���9>��u=���=�~0�;˽�9���A>iΉ=v�<D���10<H����U�g�-<�ݡ>RU�=z��=��μ����Gb>s6�=�X���=x�<       ӡ�?1��?�>m?�_c?7D�?pYl?[�c@e8�?CY�?3�f?�n?�Z�?�a@�7�?�X?�n�?d?.��?�B�?#��?       T��>^9]���">�(�<i�ֽ9�$>���	�=~.-=����=c],���t���e���=�K=���=�� ��fC=�m�       J�Q?K��?{{{?S{�?���?�o?kR�?\�i?�Tg?��?R��?j�L?���?W(j?�!�?���?��_?��??�_w?B̎?